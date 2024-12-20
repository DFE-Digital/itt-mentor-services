require "rails_helper"

RSpec.describe Claims::ProviderRejectedClaimWizard::MentorTrainingStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::ProviderRejectedClaimWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(claim: claim, mentor_trainings: claim.mentor_trainings)
    end
  end
  let(:claim) { create(:claim) }
  let(:attributes) { nil }
  let(:mentor_jane_doe) { create(:claims_mentor, first_name: "Jane", last_name: "Doe") }
  let(:mentor_john_smith) { create(:claims_mentor, first_name: "John", last_name: "Smith") }
  let(:mentor_training_1) { create(:mentor_training, claim:, mentor: mentor_jane_doe) }
  let(:mentor_training_2) { create(:mentor_training, claim:, mentor: mentor_john_smith) }

  describe "attributes" do
    it { is_expected.to have_attributes(mentor_training_ids: []) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:claim).to(:wizard) }
    it { is_expected.to delegate_method(:mentor_trainings).to(:wizard) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:mentor_training_ids) }
  end

  describe "#mentor_training_ids" do
    let(:attributes) do
      { mentor_training_ids: [mentor_training_1.id, mentor_training_2.id, "abcd", nil] }
    end

    before do
      mentor_training_1
      mentor_training_2
    end

    it "returns only returns the IDs of mentor trainings associated with the claim" do
      expect(step.mentor_training_ids).to contain_exactly(mentor_training_1.id, mentor_training_2.id)
    end
  end
end
