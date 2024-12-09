require "rails_helper"

RSpec.describe Claims::UploadSamplingDataWizard::UploadStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadSamplingDataWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:paid_claims).and_return(Claims::Claim.paid)
    end
  end
  let(:paid_claims) { [create(:claim, :submitted, status: :paid, reference: 11_111_111)] }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(csv_upload: nil, csv_content: nil, claim_ids: []) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:paid_claims).to(:wizard) }
  end

  describe "validations" do
    describe "#csv_upload" do
      context "when the csv_content is blank" do
        it { is_expected.to validate_presence_of(:csv_upload) }
      end

      context "when the csv_content is present" do
        let(:csv_content) { "claim_reference,sample_reason\r\n11111111,ABCD" }
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
          let(:paid_claims) { [create(:claim, :submitted, status: :paid, reference: 11_111_111)] }
          let(:attributes) { { csv_upload: valid_file } }
          let(:valid_file) do
            ActionDispatch::Http::UploadedFile.new({
              filename: "valid.csv",
              type: "text/csv",
              tempfile: File.open("spec/fixtures/claims/sampling/example_sampling_upload.csv"),
            })
          end

          before { paid_claims }

          it "validates that the file is the correct format" do
            expect(step.valid?).to be(true)
          end
        end
      end
    end

    describe "#csv_contains_valid_claims" do
      context "when the CSV contains claims which are not in the paid status" do
        let(:paid_claims) { [create(:claim, :submitted, status: :paid, reference: 11_111_111)] }
        let(:submitted_claim) { create(:claim, :submitted, reference: 22_222_222) }
        let(:attributes) { { csv_upload: invalid_file } }
        let(:invalid_file) do
          ActionDispatch::Http::UploadedFile.new({
            filename: "invalid.csv",
            type: "text/csv",
            tempfile: File.open("spec/fixtures/claims/sampling/invalid_example_sampling_upload.csv"),
          })
        end

        before do
          paid_claims
          submitted_claim
        end

        it "validates that the file is the correct format" do
          expect(step.valid?).to be(false)
          expect(step.errors.messages[:csv_upload]).to include("The selected CSV file contains invalid data")
        end
      end

      context "when the CSV contains only claims which are in the paid status" do
        let(:paid_claims) { [create(:claim, :submitted, status: :paid, reference: 11_111_111)] }
        let(:submitted_claim) { create(:claim, :submitted, reference: 22_222_222) }
        let(:attributes) { { csv_upload: valid_file } }
        let(:valid_file) do
          ActionDispatch::Http::UploadedFile.new({
            filename: "valid.csv",
            type: "text/csv",
            tempfile: File.open("spec/fixtures/claims/sampling/example_sampling_upload.csv"),
          })
        end

        before { paid_claims }

        it "validates that the file is the correct format" do
          expect(step.valid?).to be(true)
        end
      end
    end
  end

  describe "#process_csv" do
    let(:paid_claims) { [create(:claim, :submitted, status: :paid, reference: 11_111_111)] }
    let(:submitted_claim) { create(:claim, :submitted, reference: 22_222_222) }
    let(:attributes) { { csv_upload: valid_file } }
    let(:valid_file) do
      ActionDispatch::Http::UploadedFile.new({
        filename: "valid.csv",
        type: "text/csv",
        tempfile: File.open("spec/fixtures/claims/sampling/example_sampling_upload.csv"),
      })
    end

    before { paid_claims }

    it "reads a given CSV and assigns the content to the csv_content attribute,
      and assigns the associated claim IDs to the claim_ids attribute" do
      expect(step.csv_content).to eq("claim_reference,sample_reason\n11111111,Some Reason")
    end
  end
end
