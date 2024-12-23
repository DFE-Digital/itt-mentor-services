require "rails_helper"

RSpec.describe Claims::ProviderRejectedClaimWizard::CheckYourAnswersStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::ProviderRejectedClaimWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(claim: claim, mentor_trainings: claim.mentor_trainings)
    end
  end
  let(:claim) { create(:claim) }
  let(:attributes) { nil }

  describe "delegations" do
    it { is_expected.to delegate_method(:claim).to(:wizard) }
    it { is_expected.to delegate_method(:mentor_trainings).to(:wizard) }
  end
end
