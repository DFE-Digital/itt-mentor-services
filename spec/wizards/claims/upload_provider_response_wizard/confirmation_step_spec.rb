require "rails_helper"

RSpec.describe Claims::UploadProviderResponseWizard::ConfirmationStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadProviderResponseWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(sampled_claims: Claims::Claim.sampling_in_progress, steps: { upload: mock_upload_step })
    end
  end
  let(:mock_upload_step) do
    instance_double(Claims::UploadProviderResponseWizard::UploadStep).tap do |mock_upload_step|
      allow(mock_upload_step).to receive_messages(
        invalid_claim_rows:,
        missing_mentor_training_claim_references:,
        invalid_mentor_full_name_rows:,
        invalid_claim_accepted_rows:,
        missing_rejection_reason_rows:,
        file_name:,
        csv:,
        grouped_csv_rows:,
      )
    end
  end
  let(:attributes) { nil }
  let(:invalid_claim_rows) { nil }
  let(:missing_mentor_training_claim_references) { nil }
  let(:invalid_mentor_full_name_rows) { nil }
  let(:invalid_claim_accepted_rows) { nil }
  let(:missing_rejection_reason_rows) { nil }
  let(:file_name) { "uploaded.csv" }
  let(:csv) { CSV.parse(csv_content, headers: true, skip_blanks: true) }
  let(:csv_content) do
    "claim_reference,mentor_full_name,claim_accepted,rejection_reason\r\n" \
    "11111111,John Smith,yes,Some reason\r\n" \
    "22222222,Jane Doe,no,Another reason"
  end
  let(:grouped_csv_rows) do
    csv.group_by { |row| row["claim_reference"] }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:grouped_csv_rows).to(:upload_step) }
    it { is_expected.to delegate_method(:csv).to(:upload_step) }
    it { is_expected.to delegate_method(:file_name).to(:upload_step) }
  end

  describe "#claims_count" do
    it "returns the number of keys returned by the upload steps grouping of claims references" do
      expect(step.claims_count).to eq(2)
    end
  end

  describe "#csv_headers" do
    it "returns the headers of the CSV file" do
      expect(step.csv_headers).to match_array(
        %w[claim_reference mentor_full_name claim_accepted rejection_reason],
      )
    end
  end
end
