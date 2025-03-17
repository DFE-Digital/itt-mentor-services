require "rails_helper"

RSpec.describe Claims::OnboardMultipleSchoolsWizard::ConfirmationStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::OnboardMultipleSchoolsWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(steps: { upload: mock_upload_step })
    end
  end
  let(:mock_upload_step) do
    instance_double(Claims::OnboardMultipleSchoolsWizard::UploadStep).tap do |mock_upload_step|
      allow(mock_upload_step).to receive_messages(
        invalid_school_name_rows:,
        invalid_school_urn_rows:,
        file_name:,
        csv:,
      )
    end
  end
  let(:attributes) { nil }
  let(:invalid_school_name_rows) { nil }
  let(:invalid_school_urn_rows) { nil }
  let(:file_name) { "uploaded.csv" }
  let(:csv) { CSV.parse(csv_content, headers: true, skip_blanks: true) }
  let(:csv_content) do
    "name,urn\r\n" \
    "London School,111111"
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:csv).to(:upload_step) }
    it { is_expected.to delegate_method(:file_name).to(:upload_step) }
  end

  describe "#csv_headers" do
    it "returns the headers of the CSV file" do
      expect(step.csv_headers).to match_array(
        %w[name urn],
      )
    end
  end
end
