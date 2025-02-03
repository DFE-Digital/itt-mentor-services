require "rails_helper"

RSpec.describe Claims::UploadPayerPaymentResponseWizard::UploadErrorsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadPayerPaymentResponseWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(payment_in_progress_claims: Claims::Claim.payment_in_progress, steps: { upload: mock_upload_step })
    end
  end
  let(:mock_upload_step) do
    instance_double(Claims::UploadPayerPaymentResponseWizard::UploadStep).tap do |mock_upload_step|
      allow(mock_upload_step).to receive_messages(
        csv_content:,
        file_name:,
        invalid_claim_rows:,
        invalid_claim_status_rows:,
        invalid_claim_unpaid_reason_rows:,
      )
    end
  end
  let(:attributes) { nil }
  let(:csv_content) { nil }
  let(:file_name) { nil }
  let(:invalid_claim_rows) { [] }
  let(:invalid_claim_status_rows) { [] }
  let(:invalid_claim_unpaid_reason_rows) { [] }

  describe "delegations" do
    it { is_expected.to delegate_method(:invalid_claim_rows).to(:upload_step) }
    it { is_expected.to delegate_method(:invalid_claim_status_rows).to(:upload_step) }
    it { is_expected.to delegate_method(:invalid_claim_unpaid_reason_rows).to(:upload_step) }
    it { is_expected.to delegate_method(:file_name).to(:upload_step) }
    it { is_expected.to delegate_method(:csv).to(:upload_step) }
  end

  describe "#row_indexes_with_errors" do
    subject(:row_indexes_with_errors) { step.row_indexes_with_errors }

    let(:invalid_claim_rows) { [1] }
    let(:invalid_claim_status_rows) { [1, 2, 3] }
    let(:invalid_claim_unpaid_reason_rows) { [1, 2, 4, 5] }

    it "merges all the validation attributes containing row numbers together (removing duplicates)" do
      expect(row_indexes_with_errors).to contain_exactly(1, 2, 3, 4, 5)
    end
  end

  describe "#error_count" do
    subject(:error_count) { step.error_count }

    let(:invalid_claim_rows) { [1] }
    let(:invalid_claim_status_rows) { [1, 2, 3, 4] }
    let(:invalid_claim_unpaid_reason_rows) { [1, 2] }

    it "adds together the number of elements in validation attribute" do
      expect(error_count).to eq(7)
    end
  end
end
