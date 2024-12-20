require "rails_helper"

RSpec.describe Claims::ProviderRejectedClaimWizard::ProviderResponseStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::ProviderRejectedClaimWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(claim: claim, mentor_trainings: claim.mentor_trainings)
    end
  end
  let(:claim) { create(:claim) }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(mentor_training_id: nil, reason_not_assured: nil) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:claim).to(:wizard) }
    it { is_expected.to delegate_method(:mentor_trainings).to(:wizard) }
    it { is_expected.to delegate_method(:mentor).to(:mentor_training) }
    it { is_expected.to delegate_method(:hours_completed).to(:mentor_training) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:mentor_training_id) }
    it { is_expected.to validate_presence_of(:reason_not_assured) }
  end
end
