require "rails_helper"

RSpec.describe Claims::UploadESFAClawbackResponseWizard::ConfirmationStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadESFAClawbackResponseWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:claims_count).and_return(2)
    end
  end
  let(:attributes) { nil }

  describe "delegations" do
    it { is_expected.to delegate_method(:claims_count).to(:wizard) }
  end
end
