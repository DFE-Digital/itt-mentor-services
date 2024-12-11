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
    it { is_expected.to have_attributes(csv_upload: nil, csv_content: nil, claim_update_details: []) }
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
          "claim_reference,mentor_full_name,claim_assured,claim_not_assured_reason\r\n" \
          "11111111,John Smith,true,Some reason"
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
              tempfile: File.open("spec/fixtures/claims/sampling/example_provider_response_upload.csv"),
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

    describe "#csv_contains_valid_claims" do
      context "when the CSV contains claims which are not in the 'sampling_in_progress' status" do
        let(:sampling_in_progress_claim) do
          create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
        end
        let(:paid_claim) do
          create(:claim, :submitted, status: :paid, reference: 22_222_222)
        end
        let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
        let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }
        let(:mentor_joe_bloggs) { create(:claims_mentor, first_name: "Joe", last_name: "Bloggs") }
        let(:attributes) { { csv_upload: valid_file } }
        let(:valid_file) do
          ActionDispatch::Http::UploadedFile.new({
            filename: "valid.csv",
            type: "text/csv",
            tempfile: File.open("spec/fixtures/claims/sampling/example_provider_response_upload.csv"),
          })
        end

        before do
          create(:mentor_training, mentor: mentor_john_smith, claim: sampling_in_progress_claim)
          create(:mentor_training, mentor: mentor_jane_doe, claim: sampling_in_progress_claim)
          create(:mentor_training, mentor: mentor_joe_bloggs, claim: paid_claim)
        end

        it "validates that the file contains invalid data" do
          expect(step.valid?).to be(false)
          expect(step.errors.messages[:csv_upload]).to include("The selected CSV file contains invalid data")
        end
      end

      context "when the CSV does not contain all of the mentors associated with a claim" do
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
            tempfile: File.open("spec/fixtures/claims/sampling/example_provider_response_upload.csv"),
          })
        end

        before do
          create(:mentor_training, mentor: mentor_john_smith, claim: sampling_in_progress_claim_1)
          create(:mentor_training, mentor: mentor_jane_doe, claim: sampling_in_progress_claim_1)
          create(:mentor_training, mentor: mentor_joe_bloggs, claim: sampling_in_progress_claim_1)
          create(:mentor_training, mentor: mentor_joe_bloggs, claim: sampling_in_progress_claim_2)
        end

        it "validates that the file contains invalid data" do
          expect(step.valid?).to be(false)
          expect(step.errors.messages[:csv_upload]).to include("The selected CSV file contains invalid data")
        end
      end

      context "when the CSV contains only claims in the 'sampling_in_progress' status,
        and all of the mentors associated with a claim" do
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
            tempfile: File.open("spec/fixtures/claims/sampling/example_provider_response_upload.csv"),
          })
        end

        before do
          create(:mentor_training, mentor: mentor_john_smith, claim: sampling_in_progress_claim_1)
          create(:mentor_training, mentor: mentor_jane_doe, claim: sampling_in_progress_claim_1)
          create(:mentor_training, mentor: mentor_joe_bloggs, claim: sampling_in_progress_claim_2)
        end

        it "validates that the file is correct" do
          expect(step.valid?).to be(true)
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
          tempfile: File.open("spec/fixtures/claims/sampling/example_provider_response_upload.csv"),
        })
      end

      before do
        create(:mentor_training, mentor: mentor_john_smith, claim: sampling_in_progress_claim_1)
        create(:mentor_training, mentor: mentor_jane_doe, claim: sampling_in_progress_claim_1)
        create(:mentor_training, mentor: mentor_joe_bloggs, claim: sampling_in_progress_claim_2)
      end

      it "reads a given CSV and assigns the content to the csv_content attribute,
        and assigns the associated claim IDs to the claim_ids attribute" do
        expect(step.csv_content).to eq(
          "claim_reference,mentor_full_name,claim_assured,claim_not_assured_reason\n" \
          "11111111,John Smith,true,Some reason\n" \
          "11111111,Jane Doe,false,Another reason\n" \
          "22222222,Joe Bloggs,true,Yet another reason",
        )
      end
    end
  end
end
