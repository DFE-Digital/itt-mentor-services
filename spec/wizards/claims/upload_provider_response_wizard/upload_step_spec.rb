require "rails_helper"

RSpec.describe Claims::UploadProviderResponseWizard::UploadStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadProviderResponseWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:sampled_claims).and_return(Claims::Claim.sampling_in_progress)
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
        missing_mentor_training_claim_references: [],
        invalid_mentor_full_name_rows: [],
        invalid_claim_accepted_rows: [],
        missing_rejection_reason_rows: [],
      )
    }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:sampled_claims).to(:wizard) }
  end

  describe "validations" do
    describe "#csv_upload" do
      context "when the csv_content is blank" do
        it { is_expected.to validate_presence_of(:csv_upload) }
      end

      context "when the csv_content is present" do
        let(:csv_content) do
          "claim_reference,mentor_full_name,claim_accepted,rejection_reason\r\n" \
          "11111111,John Smith,yes,Some reason"
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
          let(:sampling_in_progress_claim_1) do
            create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
          end
          let(:sampling_in_progress_claim_2) do
            create(:claim, :submitted, status: :sampling_in_progress, reference: 22_222_222)
          end
          let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
          let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }
          let(:mentor_joe_bloggs) { create(:claims_mentor, first_name: "Joe", last_name: "Bloggs") }
          let(:attributes) { { csv_upload: valid_file } }
          let(:valid_file) do
            ActionDispatch::Http::UploadedFile.new({
              filename: "valid.csv",
              type: "text/csv",
              tempfile: File.open("spec/fixtures/claims/sampling/provider_responses/example_provider_response_upload.csv"),
            })
          end

          before do
            create(:mentor_training, mentor: mentor_john_smith, claim: sampling_in_progress_claim_1)
            create(:mentor_training, mentor: mentor_jane_doe, claim: sampling_in_progress_claim_1)
            create(:mentor_training, mentor: mentor_joe_bloggs, claim: sampling_in_progress_claim_2)
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
              "Your file needs a column name called ‘claim_reference’, ‘mentor_full_name’, ‘claim_accepted’, and ‘rejection_reason’.",
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
        "claim_reference,mentor_full_name,claim_accepted,rejection_reason\r\n" \
        "11111111,John Smith,yes,Some reason"
      end
      let(:attributes) { { csv_content: } }

      before { create(:claim, :submitted, status: :paid, reference: 22_222_222) }

      it "returns false and assigns the csv row to the 'invalid_claim_rows' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_claim_rows).to contain_exactly(0)
      end
    end

    context "when csv_content contains claims not with the status 'sampling_in_progress" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,claim_accepted,rejection_reason\r\n" \
        "11111111,John Smith,yes,Some reason"
      end
      let(:attributes) { { csv_content: } }

      before { create(:claim, :submitted, status: :paid, reference: 11_111_111) }

      it "returns false and assigns the csv row to the 'invalid_claim_rows' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_claim_rows).to contain_exactly(0)
      end
    end

    context "when csv_content does not contains all the mentors associated with the claims" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,claim_accepted,rejection_reason\r\n" \
        "11111111,John Smith,yes,Some reason"
      end
      let(:attributes) { { csv_content: } }

      let(:sampling_in_progress_claim) do
        create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
      end
      let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
      let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }

      before do
        create(:mentor_training, mentor: mentor_john_smith, claim: sampling_in_progress_claim)
        create(:mentor_training, mentor: mentor_jane_doe, claim: sampling_in_progress_claim)
      end

      it "returns false and assigns the reference to the 'missing_mentor_training_claim_references' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.missing_mentor_training_claim_references).to contain_exactly("11111111")
      end
    end

    context "when the csv_content contains a mentor not associated with the claims" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,claim_accepted,rejection_reason\r\n" \
        "11111111,Random Bob,yes,Some reason"
      end
      let(:attributes) { { csv_content: } }

      let(:sampling_in_progress_claim) do
        create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
      end
      let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }

      before do
        create(:mentor_training, mentor: mentor_john_smith, claim: sampling_in_progress_claim)
      end

      it "returns false and assigns the csv row to the 'invalid_mentor_full_name_rows' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_mentor_full_name_rows).to contain_exactly(0)
      end
    end

    context "when the csv_content does not contain a claim accepted input for each mentor" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,claim_accepted,rejection_reason\r\n" \
        "11111111,John Smith,,Some reason"
      end
      let(:attributes) { { csv_content: } }

      let(:sampling_in_progress_claim) do
        create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
      end
      let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }

      before do
        create(:mentor_training, mentor: mentor_john_smith, claim: sampling_in_progress_claim)
      end

      it "returns false and assigns the csv row to the 'invalid_claim_accepted_rows' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.invalid_claim_accepted_rows).to contain_exactly(0)
      end
    end

    context "when the csv_content does not contain a rejection reason" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,claim_accepted,rejection_reason\r\n" \
        "11111111,John Smith,no,"
      end
      let(:attributes) { { csv_content: } }

      let(:sampling_in_progress_claim) do
        create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
      end
      let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }

      before do
        create(:mentor_training, mentor: mentor_john_smith, claim: sampling_in_progress_claim)
      end

      it "returns false and assigns the reference to the 'missing_rejection_reason_rows' attribute" do
        expect(csv_inputs_valid).to be(false)
        expect(step.missing_rejection_reason_rows).to contain_exactly(0)
      end
    end

    context "when the csv_content contains valid claim references and all necessary attributes" do
      let(:csv_content) do
        "claim_reference,mentor_full_name,claim_accepted,rejection_reason\r\n" \
        "11111111,John Smith,no,Some reason"
      end
      let(:attributes) { { csv_content: } }

      let(:sampling_in_progress_claim) do
        create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
      end
      let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }

      before do
        create(:mentor_training, mentor: mentor_john_smith, claim: sampling_in_progress_claim)
      end

      it "returns true" do
        expect(csv_inputs_valid).to be(true)
      end
    end
  end

  describe "#process_csv" do
    let(:sampling_in_progress_claim_1) do
      create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
    end
    let(:sampling_in_progress_claim_2) do
      create(:claim, :submitted, status: :sampling_in_progress, reference: 22_222_222)
    end
    let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
    let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }
    let(:mentor_joe_bloggs) { create(:claims_mentor, first_name: "Joe", last_name: "Bloggs") }
    let(:attributes) { { csv_upload: valid_file } }
    let(:valid_file) do
      ActionDispatch::Http::UploadedFile.new({
        filename: "valid.csv",
        type: "text/csv",
        tempfile: File.open("spec/fixtures/claims/sampling/provider_responses/example_provider_response_upload.csv"),
      })
    end

    before do
      create(:mentor_training, mentor: mentor_john_smith, claim: sampling_in_progress_claim_1)
      create(:mentor_training, mentor: mentor_jane_doe, claim: sampling_in_progress_claim_1)
      create(:mentor_training, mentor: mentor_joe_bloggs, claim: sampling_in_progress_claim_2)
    end

    it "reads a given CSV and assigns the content to the csv_content attribute,
      and assigns the file name" do
      expect(step.csv_content).to eq(
        "claim_reference,mentor_full_name,claim_accepted,rejection_reason\n" \
        "11111111,John Smith,yes,Some reason\n" \
        "11111111,Jane Doe,no,Another reason\n" \
        "22222222,Joe Bloggs,yes,Yet another reason\n" \
        ",,,,\n",
      )
      expect(step.file_name).to eq("valid.csv")
    end
  end

  describe "#grouped_csv_rows" do
    subject(:grouped_csv_rows) { step.grouped_csv_rows }

    let(:csv_content) do
      "claim_reference,mentor_full_name,claim_accepted,rejection_reason\r\n" \
      "11111111,John Smith,no,Some reason\r\n" \
      "11111111,Jane Doe,yes,Another reason\r\n" \
      "22222222,Joe Bloggs,yes,A reason"
    end
    let(:attributes) { { csv_content: } }

    it "returns the rows of the CSV grouped by references" do
      expect(grouped_csv_rows["11111111"].map(&:to_hash)).to contain_exactly(
        {
          "claim_reference" => "11111111",
          "mentor_full_name" => "John Smith",
          "claim_accepted" => "no",
          "rejection_reason" => "Some reason",
        },
        {
          "claim_reference" => "11111111",
          "mentor_full_name" => "Jane Doe",
          "claim_accepted" => "yes",
          "rejection_reason" => "Another reason",
        },
      )
      expect(grouped_csv_rows["22222222"].map(&:to_hash)).to contain_exactly(
        {
          "claim_reference" => "22222222",
          "mentor_full_name" => "Joe Bloggs",
          "claim_accepted" => "yes",
          "rejection_reason" => "A reason",
        },
      )
    end
  end

  describe "#csv" do
    subject(:csv) { step.csv }

    let(:csv_content) do
      "claim_reference,mentor_full_name,claim_accepted,rejection_reason\r\n" \
      "11111111,John Smith,no,Some reason\r\n" \
      "11111111,Jane Doe,yes,Another reason\r\n" \
      "22222222,Joe Bloggs,yes,A reason\r\n" \
      ""
    end
    let(:attributes) { { csv_content: } }

    it "converts the csv content into a CSV record" do
      expect(csv).to be_a(CSV::Table)
      expect(csv.headers).to match_array(
        %w[claim_reference mentor_full_name claim_accepted rejection_reason],
      )
      expect(csv.count).to eq(3)

      expect(csv[0]).to be_a(CSV::Row)
      expect(csv[0].to_h).to eq({
        "claim_reference" => "11111111",
        "mentor_full_name" => "John Smith",
        "claim_accepted" => "no",
        "rejection_reason" => "Some reason",
      })

      expect(csv[1]).to be_a(CSV::Row)
      expect(csv[1].to_h).to eq({
        "claim_reference" => "11111111",
        "mentor_full_name" => "Jane Doe",
        "claim_accepted" => "yes",
        "rejection_reason" => "Another reason",
      })

      expect(csv[2]).to be_a(CSV::Row)
      expect(csv[2].to_h).to eq({
        "claim_reference" => "22222222",
        "mentor_full_name" => "Joe Bloggs",
        "claim_accepted" => "yes",
        "rejection_reason" => "A reason",
      })
    end
  end
end
