require "rails_helper"

RSpec.describe Claims::OnboardMultipleSchoolsWizard::UploadErrorsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::OnboardMultipleSchoolsWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(steps: { upload: mock_upload_step })
    end
  end
  let(:mock_upload_step) do
    instance_double(Claims::OnboardMultipleSchoolsWizard::UploadStep).tap do |mock_upload_step|
      allow(mock_upload_step).to receive_messages(
        csv_content:,
        file_name:,
        invalid_school_name_rows:,
        invalid_school_urn_rows:,
      )
    end
  end
  let(:attributes) { nil }
  let(:csv_content) { nil }
  let(:file_name) { nil }
  let(:invalid_school_name_rows) { [] }
  let(:invalid_school_urn_rows) { [] }

  describe "delegations" do
    it { is_expected.to delegate_method(:invalid_school_name_rows).to(:upload_step) }
    it { is_expected.to delegate_method(:invalid_school_urn_rows).to(:upload_step) }
    it { is_expected.to delegate_method(:file_name).to(:upload_step) }
    it { is_expected.to delegate_method(:csv).to(:upload_step) }
  end

  describe "#row_indexes_with_errors" do
    subject(:row_indexes_with_errors) { step.row_indexes_with_errors }

    let(:invalid_school_name_rows) { [1] }
    let(:invalid_school_urn_rows) { [1, 2, 3] }

    it "merges all the validation attributes containing row numbers together (removing duplicates)" do
      expect(row_indexes_with_errors).to contain_exactly(1, 2, 3)
    end
  end

  describe "#error_count" do
    subject(:error_count) { step.error_count }

    let(:invalid_school_name_rows) { [1] }
    let(:invalid_school_urn_rows) { [1, 2, 3, 4] }

    it "adds together the number of elements in validation attribute" do
      expect(error_count).to eq(5)
    end
  end
end
