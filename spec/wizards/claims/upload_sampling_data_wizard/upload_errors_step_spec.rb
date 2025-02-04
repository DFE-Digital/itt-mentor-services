require "rails_helper"

RSpec.describe Claims::UploadSamplingDataWizard::UploadErrorsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadSamplingDataWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(paid_claims: Claims::Claim.paid, steps: { upload: mock_upload_step })
    end
  end
  let(:mock_upload_step) do
    instance_double(Claims::UploadSamplingDataWizard::UploadStep).tap do |mock_upload_step|
      allow(mock_upload_step).to receive_messages(
        invalid_claim_rows:,
        missing_sample_reason_rows:,
        file_name:,
        csv:,
      )
    end
  end
  let(:attributes) { nil }
  let(:invalid_claim_rows) { nil }
  let(:missing_sample_reason_rows) { nil }
  let(:file_name) { "uploaded.csv" }
  let(:csv) { CSV.parse(csv_content, headers: true, skip_blanks: true) }
  let(:csv_content) do
    "claim_reference,sample_reason\r\n" \
    "11111111,Some reason\r\n" \
  end

  let(:claim_1) { create(:claim, :submitted, status: :paid, reference: 11_111_111) }
  let(:claim_2) { create(:claim, :submitted, status: :paid, reference: 22_222_222) }
  let(:claim_3) { create(:claim, :submitted, status: :paid, reference: 33_333_333) }

  before do
    claim_1
    claim_2
    claim_3
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:invalid_claim_rows).to(:upload_step) }
    it { is_expected.to delegate_method(:missing_sample_reason_rows).to(:upload_step) }
    it { is_expected.to delegate_method(:file_name).to(:upload_step) }
    it { is_expected.to delegate_method(:csv).to(:upload_step) }
  end

  describe "#row_indexes_with_errors" do
    subject(:row_indexes_with_errors) { step.row_indexes_with_errors }

    let(:invalid_claim_rows) { [1] }
    let(:missing_sample_reason_rows) { [1, 5] }

    it "merges all the validation attributes containing row numbers together (removing duplicates)" do
      expect(row_indexes_with_errors).to contain_exactly(1, 5)
    end
  end

  describe "#error_count" do
    subject(:error_count) { step.error_count }

    let(:invalid_claim_rows) { [1] }
    let(:missing_sample_reason_rows) { [1, 2, 3, 4, 5] }

    it "adds together the number of elements in validation attribute" do
      expect(error_count).to eq(6)
    end
  end
end
