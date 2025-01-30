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
        file_name: nil,
        invalid_claim_rows: [],
        invalid_claim_status_rows: [],
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
          "claim_reference,claim_status\r\n" \
          "11111111,clawback_complete\r\n"
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

    describe "#validate_csv_headers" do
      context "when csv_content is present" do
        context "when the csv content is missing valid headers" do
          let(:csv_content) do
            "something_random\r\n" \
            "blah"
          end
          let(:attributes) { { csv_content: } }

          it "returns errors for missing headers" do
            expect(step.valid?).to be(false)
            expect(step.errors.messages[:csv_upload]).to include(
              "Your file needs a column called ‘claim_reference’ and ‘claim_status’.",
            )
            expect(step.errors.messages[:csv_upload]).to include(
              "Right now it has columns called ‘something_random’.",
            )
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
        "claim_reference,claim_status\r\n" \
        "11111111,clawback_complete\r\n"
      end
      let(:attributes) { { csv_content: } }

      before { create(:claim, :submitted, status: :paid, reference: 22_222_222) }

      it "returns false and assigns the csv row to the 'invalid_claim_rows' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_claim_rows).to contain_exactly(0)
      end
    end

    context "when csv_content contains claims not with the status 'clawback_in_progress" do
      let(:csv_content) do
        "claim_reference,claim_status\r\n" \
        "11111111,clawback_complete\r\n"
      end
      let(:attributes) { { csv_content: } }

      before { create(:claim, :submitted, status: :paid, reference: 11_111_111) }

      it "returns false and assigns the csv row to the 'invalid_claim_rows' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_claim_rows).to contain_exactly(0)
      end
    end

    context "when csv_content contains an invalid claims status" do
      let(:csv_content) do
        "claim_reference,claim_status\r\n" \
        "11111111,paid\r\n"
      end
      let(:attributes) { { csv_content: } }

      before { create(:claim, :submitted, status: :paid, reference: 11_111_111) }

      it "returns false and assigns the reference to the 'invalid_claim_status_rows' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_claim_status_rows).to contain_exactly(0)
      end
    end

    context "when the csv_content contains valid claim references and all necessary valid attributes" do
      let(:csv_content) do
        "claim_reference,claim_status\r\n" \
        "11111111,clawback_complete\r\n"
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
        "claim_reference,claim_status\n" \
        "11111111,clawback_complete\n" \
        "22222222,clawback_complete\n" \
        ",\n",
      )
    end
  end

  describe "#csv" do
    subject(:csv) { step.csv }

    let(:csv_content) do
      "claim_reference,claim_status\r\n" \
      "11111111,clawback_complete\r\n" \
      "22222222,clawback_in_progress\r\n" \
      ""
    end
    let(:attributes) { { csv_content: } }

    it "converts the csv content into a CSV record" do
      expect(csv).to be_a(CSV::Table)
      expect(csv.headers).to match_array(
        %w[claim_reference claim_status],
      )
      expect(csv.count).to eq(2)

      expect(csv[0]).to be_a(CSV::Row)
      expect(csv[0].to_h).to eq({
        "claim_reference" => "11111111",
        "claim_status" => "clawback_complete",
      })

      expect(csv[1]).to be_a(CSV::Row)
      expect(csv[1].to_h).to eq({
        "claim_reference" => "22222222",
        "claim_status" => "clawback_in_progress",
      })
    end
  end
end
