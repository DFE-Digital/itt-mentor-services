require "rails_helper"

RSpec.describe Claims::OnboardProvidersWizard::ConfirmationStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::OnboardProvidersWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(steps: { upload: mock_upload_step })
    end
  end
  let(:mock_upload_step) do
    instance_double(Claims::OnboardProvidersWizard::UploadStep).tap do |mock_upload_step|
      allow(mock_upload_step).to receive_messages(
        file_name:,
        csv:,
      )
    end
  end
  let(:attributes) { nil }
  let(:file_name) { "uploaded.csv" }
  let(:csv) { CSV.parse(csv_content, headers: true, skip_blanks: true) }
  let(:csv_content) do
    "provider_name,provider_code,first_name,last_name,email\r\n" \
    "London Provider,ABC,John,Smith,john_smith@example.com"
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:csv).to(:upload_step) }
    it { is_expected.to delegate_method(:file_name).to(:upload_step) }
  end

  describe "#csv_headers" do
    it "returns CSV headers" do
      expect(step.csv_headers).to match_array(
        %w[provider_name provider_code first_name last_name email],
      )
    end
  end
end
