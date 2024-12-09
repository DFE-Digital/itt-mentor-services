require "rails_helper"

RSpec.describe Claims::UploadSamplingDataWizard::ConfirmationStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadSamplingDataWizard)
  end
  let(:attributes) { nil }

  describe "delegations" do
    it { is_expected.to delegate_method(:uploaded_claim_ids).to(:wizard) }
  end
end
