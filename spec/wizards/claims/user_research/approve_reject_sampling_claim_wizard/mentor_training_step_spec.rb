require "rails_helper"

RSpec.describe Claims::UserResearch::ApproveRejectSamplingClaimWizard::MentorTrainingStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:claim) { create(:claim) }
  let(:mentor) { create(:claims_mentor) }
  let(:provider) { create(:claims_provider) }
  let(:mentor_training) do
    create(:mentor_training, claim:, mentor:, provider:, hours_completed: 8, training_type: :refresher)
  end
  let(:mentor_trainings) { [mentor_training] }
  let(:action) { "reject" }
  let(:mock_wizard) { instance_double(Claims::UserResearch::ApproveRejectSamplingClaimWizard, mentor_trainings:, action:) }
  let(:attributes) do
    {
      mentor_id: mentor.id,
      hours_option: described_class::CUSTOM_HOURS,
      custom_hours: "3",
      reason_not_assured: "Not enough evidence",
    }
  end

  describe "lookups and fallbacks" do
    it "returns values from the matched mentor training" do
      expect(step.mentor).to eq(mentor)
      expect(step.provider).to eq(provider)
      expect(step.max_hours).to eq(8)
      expect(step.training_type).to eq("refresher")
    end

    context "when no mentor training matches the mentor id" do
      let(:attributes) { { mentor_id: "missing-id", hours_option: described_class::REMOVE_ALL_HOURS, reason_not_assured: "Reason" } }

      it "returns nils with fallback values" do
        expect(step.mentor).to be_nil
        expect(step.provider).to be_nil
        expect(step.max_hours).to eq(0)
        expect(step.training_type).to eq(:initial)
      end
    end
  end

  describe "#completed_hours" do
    context "when removing all hours" do
      let(:attributes) do
        {
          mentor_id: mentor.id,
          hours_option: described_class::REMOVE_ALL_HOURS,
          reason_not_assured: "Not enough evidence",
        }
      end

      it "returns zero" do
        expect(step.completed_hours).to eq(0)
      end
    end

    context "when custom hours are entered" do
      it "returns the entered hours" do
        expect(step.completed_hours).to eq(3)
      end
    end
  end

  describe "custom hours validation" do
    let(:attributes) do
      {
        mentor_id: mentor.id,
        hours_option: described_class::CUSTOM_HOURS,
        custom_hours: "99",
        reason_not_assured: "Not enough evidence",
      }
    end

    it "adds a range validation error for out-of-range values" do
      expect(step).not_to be_valid
      expect(step.errors[:custom_hours]).to include("Enter a number of hours between 1 and 8")
    end

    context "when custom hours are within range" do
      let(:attributes) do
        {
          mentor_id: mentor.id,
          hours_option: described_class::CUSTOM_HOURS,
          custom_hours: "3",
          reason_not_assured: "Not enough evidence",
        }
      end

      it "is valid" do
        expect(step).to be_valid
      end
    end

    context "when custom hours are blank" do
      let(:attributes) do
        {
          mentor_id: mentor.id,
          hours_option: described_class::CUSTOM_HOURS,
          custom_hours: "",
          reason_not_assured: "Not enough evidence",
        }
      end

      it "adds the range validation error" do
        expect(step).not_to be_valid
        expect(step.errors[:custom_hours]).to include("Enter a number of hours between 1 and 8")
      end
    end

    context "when custom hours are non-numeric" do
      let(:attributes) do
        {
          mentor_id: mentor.id,
          hours_option: described_class::CUSTOM_HOURS,
          custom_hours: "abc",
          reason_not_assured: "Not enough evidence",
        }
      end

      it "adds the range validation error" do
        expect(step).not_to be_valid
        expect(step.errors[:custom_hours]).to include("Enter a number of hours between 1 and 8")
      end
    end
  end
end
