require "rails_helper"

RSpec.describe Claims::UploadESFAClawbackResponseWizard::UploadStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadESFAClawbackResponseWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:clawback_in_progress_claims).and_return(Claims::Claim.clawback_in_progress)
    end
  end
  let(:attributes) { nil }

  describe "attributes" do
    it {
      expect(step).to have_attributes(
        csv_upload: nil,
        csv_content: nil,
        invalid_claim_references: [],
        invalid_status_claim_references: [],
        missing_mentor_training_claim_references: [],
        missing_reason_clawed_back_claim_references: [],
        invalid_hours_clawed_back_claim_references: [],
      )
    }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:clawback_in_progress_claims).to(:wizard) }
  end

  describe "validations" do
    describe "#csv_upload" do
      context "when the csv_content is blank" do
        it { is_expected.to validate_presence_of(:csv_upload) }
      end

      context "when the csv_content is present" do
        let(:csv_content) do
          "claim_reference,mentor_full_name,reason_clawed_back,hours_clawed_back\r\n" \
          "11111111,John Smith,Some reason,10\r\n"
        end
        let(:attributes) { { csv_content: } }

        it { is_expected.not_to validate_presence_of(:csv_upload) }
      end
    end

    describe "#validate_csv_file" do
      context "when the csv_upload is present" do
        context "when the csv_upload is not a CSV" do
          let(:attributes) { { csv_upload: invalid_file } }
          let(:invalid_file) do
            ActionDispatch::Http::UploadedFile.new({
              filename: "invalid.jpg",
              type: "image/jpeg",
              tempfile: Tempfile.new("invalid.jpg"),
            })
          end

          it "validates that the file is the incorrect format" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:csv_upload]).to include("The selected file must be a CSV")
          end
        end

        context "when the csv_upload is a CSV file" do
          let(:clawback_in_progress_claim_1) do
            create(:claim, :submitted, status: :clawback_in_progress, reference: 11_111_111)
          end
          let(:clawback_in_progress_claim_2) do
            create(:claim, :submitted, status: :clawback_in_progress, reference: 22_222_222)
          end
          let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
          let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }
          let(:mentor_joe_bloggs) { create(:claims_mentor, first_name: "Joe", last_name: "Bloggs") }
          let(:attributes) { { csv_upload: valid_file } }
          let(:valid_file) do
            ActionDispatch::Http::UploadedFile.new({
              filename: "valid.csv",
              type: "text/csv",
              tempfile: File.open(
                "spec/fixtures/claims/clawback/esfa_responses/example_esfa_clawback_response_upload.csv",
              ),
            })
          end

          before do
            create(:mentor_training,
                   :rejected,
                   hours_completed: 20,
                   mentor: mentor_john_smith,
                   claim: clawback_in_progress_claim_1)
            create(:mentor_training,
                   :rejected,
                   hours_completed: 10,
                   mentor: mentor_jane_doe,
                   claim: clawback_in_progress_claim_1)
            create(:mentor_training,
                   :rejected,
                   hours_completed: 2,
                   mentor: mentor_joe_bloggs,
                   claim: clawback_in_progress_claim_2)
          end

          it "validates that the file is the correct format" do
            expect(step.valid?).to be(true)
          end
        end
      end
    end
  end

  describe "#csv_inputs_valid?" do
    subject(:csv_inputs_valid) { step.csv_inputs_valid? }

    context "when the csv_content is blank" do
      it "returns true" do
        expect(csv_inputs_valid).to be(true)
      end
    end

    context "when csv_content contains invalid references" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,reason_clawed_back,hours_clawed_back\r\n" \
        "11111111,John Smith,Some reason,10\r\n" \
      end
      let(:attributes) { { csv_content: } }

      before { create(:claim, :submitted, status: :paid, reference: 22_222_222) }

      it "returns false and assigns the reference to the 'invalid_claim_references' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_claim_references).to contain_exactly("11111111")
      end
    end

    context "when csv_content contains claims not with the status 'clawback_in_progress" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,reason_clawed_back,hours_clawed_back\r\n" \
        "11111111,John Smith,Some reason,10"
      end
      let(:attributes) { { csv_content: } }

      before { create(:claim, :submitted, status: :paid, reference: 11_111_111) }

      it "returns false and assigns the reference to the 'invalid_status_claim_references' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_status_claim_references).to contain_exactly("11111111")
      end
    end

    context "when csv_content does not contains all the not assured mentors associated with the claims" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,reason_clawed_back,hours_clawed_back\r\n" \
        "11111111,John Smith,Some reason,10"
      end
      let(:attributes) { { csv_content: } }

      let(:sampling_in_progress_claim) do
        create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
      end
      let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
      let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }

      before do
        create(:mentor_training,
               :rejected,
               hours_completed: 20,
               mentor: mentor_john_smith,
               claim: sampling_in_progress_claim)
        create(:mentor_training,
               :rejected,
               hours_completed: 10,
               mentor: mentor_jane_doe,
               claim: sampling_in_progress_claim)
      end

      it "returns false and assigns the reference to the 'missing_mentor_training_claim_references' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.missing_mentor_training_claim_references).to contain_exactly("11111111")
      end
    end

    context "when the csv_content does not contain a reason clawed back for each mentor" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,reason_clawed_back,hours_clawed_back\r\n" \
        "11111111,John Smith,,10"
      end
      let(:attributes) { { csv_content: } }
      let(:clawback_in_progress_claim) do
        create(:claim, :submitted, status: :clawback_in_progress, reference: 11_111_111)
      end
      let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }

      before do
        create(:mentor_training,
               :rejected,
               hours_completed: 20,
               mentor: mentor_john_smith,
               claim: clawback_in_progress_claim)
      end

      it "returns false and assigns the reference to the 'missing_reason_clawed_back_claim_references' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.missing_reason_clawed_back_claim_references).to contain_exactly("11111111")
      end
    end

    context "when the csv_content does not contain hours clawed back for each mentor" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,reason_clawed_back,hours_clawed_back\r\n" \
        "11111111,John Smith,Some reason,"
      end
      let(:attributes) { { csv_content: } }
      let(:clawback_in_progress_claim) do
        create(:claim, :submitted, status: :clawback_in_progress, reference: 11_111_111)
      end
      let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }

      before do
        create(:mentor_training,
               :rejected,
               hours_completed: 20,
               mentor: mentor_john_smith,
               claim: clawback_in_progress_claim)
      end

      it "returns false and assigns the reference to the 'invalid_clawed_back_claim_references' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_hours_clawed_back_claim_references).to contain_exactly("11111111")
      end
    end

    context "when the csv_content contain hours clawed back greater than the hours completed" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,reason_clawed_back,hours_clawed_back\r\n" \
        "11111111,John Smith,Some reason,20"
      end
      let(:attributes) { { csv_content: } }
      let(:clawback_in_progress_claim) do
        create(:claim, :submitted, status: :clawback_in_progress, reference: 11_111_111)
      end
      let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }

      before do
        create(:mentor_training,
               :rejected,
               hours_completed: 5,
               mentor: mentor_john_smith,
               claim: clawback_in_progress_claim)
      end

      it "returns false and assigns the reference to the 'invalid_clawed_back_claim_references' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_hours_clawed_back_claim_references).to contain_exactly("11111111")
      end
    end

    context "when the csv_content contains valid claim references and all necessary valid attributes" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,reason_clawed_back,hours_clawed_back\r\n" \
        "11111111,John Smith,Some reason,10"
      end
      let(:attributes) { { csv_content: } }
      let(:clawback_in_progress_claim) do
        create(:claim, :submitted, status: :clawback_in_progress, reference: 11_111_111)
      end
      let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }

      before do
        create(:mentor_training,
               :rejected,
               hours_completed: 20,
               mentor: mentor_john_smith,
               claim: clawback_in_progress_claim)
      end

      it "returns true" do
        expect(csv_inputs_valid).to be(true)
      end
    end
  end

  describe "#process_csv" do
    let(:clawback_in_progress_claim_1) do
      create(:claim, :submitted, status: :clawback_in_progress, reference: 11_111_111)
    end
    let(:clawback_in_progress_claim_2) do
      create(:claim, :submitted, status: :clawback_in_progress, reference: 22_222_222)
    end
    let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
    let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }
    let(:mentor_joe_bloggs) { create(:claims_mentor, first_name: "Joe", last_name: "Bloggs") }
    let(:attributes) { { csv_upload: valid_file } }
    let(:valid_file) do
      ActionDispatch::Http::UploadedFile.new({
        filename: "valid.csv",
        type: "text/csv",
        tempfile: File.open(
          "spec/fixtures/claims/clawback/esfa_responses/example_esfa_clawback_response_upload.csv",
        ),
      })
    end

    before do
      create(:mentor_training,
             :rejected,
             hours_completed: 20,
             mentor: mentor_john_smith,
             claim: clawback_in_progress_claim_1)
      create(:mentor_training,
             :rejected,
             hours_completed: 10,
             mentor: mentor_jane_doe,
             claim: clawback_in_progress_claim_1)
      create(:mentor_training,
             :rejected,
             hours_completed: 5,
             mentor: mentor_joe_bloggs,
             claim: clawback_in_progress_claim_2)
    end

    it "reads a given CSV and assigns the content to the csv_content attribute,
        and assigns the associated claim IDs to the claim_ids attribute" do
      expect(step.csv_content).to eq(
        "claim_reference,mentor_full_name,reason_clawed_back,hours_clawed_back\n" \
        "11111111,John Smith,Some reason,10\n" \
        "11111111,Jane Doe,Another reason,5\n" \
        "22222222,Joe Bloggs,Yet another reason,2\n" \
        ",,,\n",
      )
    end
  end

  describe "#grouped_csv_rows" do
    subject(:grouped_csv_rows) { step.grouped_csv_rows }

    let(:csv_content) do
      "claim_reference,mentor_full_name,reason_clawed_back,hours_clawed_back\n" \
        "11111111,John Smith,Some reason,10\n" \
        "11111111,Jane Doe,Another reason,5\n" \
        "22222222,Joe Bloggs,Yet another reason,2"
    end
    let(:attributes) { { csv_content: } }

    it "returns the rows of the CSV grouped by references" do
      expect(grouped_csv_rows["11111111"].map(&:to_hash)).to contain_exactly(
        {
          "claim_reference" => "11111111",
          "mentor_full_name" => "John Smith",
          "reason_clawed_back" => "Some reason",
          "hours_clawed_back" => "10",
        },
        {
          "claim_reference" => "11111111",
          "mentor_full_name" => "Jane Doe",
          "reason_clawed_back" => "Another reason",
          "hours_clawed_back" => "5",
        },
      )
      expect(grouped_csv_rows["22222222"].map(&:to_hash)).to contain_exactly(
        {
          "claim_reference" => "22222222",
          "mentor_full_name" => "Joe Bloggs",
          "reason_clawed_back" => "Yet another reason",
          "hours_clawed_back" => "2",
        },
      )
    end
  end
end
