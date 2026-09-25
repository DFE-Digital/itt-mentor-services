require "rails_helper"

RSpec.describe Claims::UploadPayerPaymentResponseWizard::UploadStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadPayerPaymentResponseWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:payment_in_progress_claims).and_return(Claims::Claim.payment_in_progress)
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
        invalid_claim_unpaid_reason_rows: [],
      )
    }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:payment_in_progress_claims).to(:wizard) }
  end

  describe "validations" do
    describe "#csv_upload" do
      context "when the csv_content is blank" do
        it { is_expected.to validate_presence_of(:csv_upload) }
      end

      context "when the csv_content is present" do
        let(:csv_content) do
          "claim_reference,claim_status,claim_unpaid_reason\r\n" \
          "11111111,paid,\r\n" \
          "22222222,unpaid,Some reason"
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
            create(:claim, :payment_in_progress, reference: 11_111_111)
          end
          let(:clawback_in_progress_claim_2) do
            create(:claim, :payment_in_progress, reference: 22_222_222)
          end
          let(:attributes) { { csv_upload: valid_file } }
          let(:valid_file) do
            ActionDispatch::Http::UploadedFile.new({
              filename: "valid.csv",
              type: "text/csv",
              tempfile: File.open(
                "spec/fixtures/claims/payment/example_payer_response.csv",
              ),
            })
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
              "Your file needs a column called ‘claim_reference’, ‘claim_status’, and ‘claim_unpaid_reason’.",
            )
            expect(step.errors.messages[:csv_upload]).to include(
              "Right now it has columns called ‘something_random’.",
            )
          end
        end
      end
    end
  end
end
