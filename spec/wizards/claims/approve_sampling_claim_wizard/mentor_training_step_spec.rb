require "rails_helper"

RSpec.describe Claims::ApproveSamplingClaimWizard::MentorTrainingStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:claim) { create(:claim) }
  let(:mentor) { create(:claims_mentor) }
  let(:provider) { create(:claims_provider) }
  let(:mentor_training) do
    create(:mentor_training, claim:, mentor:, provider:, hours_completed: 9, training_type: :refresher)
  end
  let(:mentor_trainings) { [mentor_training] }
  let(:mock_wizard) { instance_double(Claims::ApproveSamplingClaimWizard, mentor_trainings:) }
  let(:attributes) { { mentor_id: mentor.id, hours_completed: 5 } }

  describe "record lookups" do
    it "finds the mentor and mentor training for the step" do
      expect(step.mentor).to eq(mentor)
      expect(step.mentor_training).to eq(mentor_training)
    end

    context "when no matching mentor training exists" do
      let(:attributes) { { mentor_id: "missing-id", hours_completed: 5 } }

      it "returns nil values and fallbacks" do
        expect(step.mentor).to be_nil
        expect(step.mentor_training).to be_nil
        expect(step.provider).to be_nil
        expect(step.max_hours).to eq(0)
        expect(step.training_type).to eq(:initial)
      end
    end
  end

  describe "derived values" do
    it "uses the mentor training values when present" do
      expect(step.provider).to eq(provider)
      expect(step.max_hours).to eq(9)
      expect(step.training_type).to eq("refresher")
    end
  end
end
