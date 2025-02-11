require "rails_helper"

RSpec.describe Claims::EditClaimWizard::DeclarationStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::EditClaimWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(claim:)
    end
  end
  let(:attributes) { nil }
  let(:claim) { build(:claim) }

  describe "delegations" do
    it { is_expected.to delegate_method(:claim).to(:wizard) }
    it { is_expected.to delegate_method(:total_hours_completed).to(:claim) }
    it { is_expected.to delegate_method(:mentors).to(:claim) }
    it { is_expected.to delegate_method(:mentor_trainings).to(:claim) }
    it { is_expected.to delegate_method(:amount).to(:claim) }
  end
end
