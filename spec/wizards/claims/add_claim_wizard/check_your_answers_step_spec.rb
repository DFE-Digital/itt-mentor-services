require "rails_helper"

RSpec.describe Claims::AddClaimWizard::CheckYourAnswersStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::AddClaimWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:claim).and_return(claim)
    end
  end
  let(:claim) { build(:claim) }
  let(:attributes) { nil }

  describe "validations" do
    describe "#mentors_have_claimable_hours" do
      context "when the claim has no mentor trainings" do
        it "returns an error" do
          expect(step.valid?).to be(false)
          expect(step.errors.messages[:base]).to include("You cannot submit the claim")
        end
      end

      context "when the claim has no more claimable training hours" do
        it "returns an error" do
          allow(claim).to receive(:valid_mentor_training_hours?).and_return(false)

          expect(step.valid?).to be(false)
          expect(step.errors.messages[:base]).to include("You cannot submit the claim")
        end
      end

      context "when the claim has mentor trainings and has claimable training hours" do
        it "returns valid" do
          allow(claim).to receive(:valid_mentor_training_hours?).and_return(true)
          claim.mentor_trainings << build(:mentor_training)

          expect(step.valid?).to be(true)
        end
      end
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:claim).to(:wizard) }
  end
end
