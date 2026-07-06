require "rails_helper"

RSpec.describe Claims::ApproveSamplingClaimWizard::MentorStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:attributes) { nil }
  let(:claim) { create(:claim) }
  let(:mentor) { create(:claims_mentor) }
  let(:mentor_training) { create(:mentor_training, claim:, mentor:) }
  let(:mock_wizard) { instance_double(Claims::ApproveSamplingClaimWizard, mentor_trainings:) }

  describe "#selected_mentors" do
    context "when there are no mentor trainings" do
      let(:mentor_trainings) { [] }

      it "returns an empty relation" do
        expect(step.selected_mentors).to eq(Claims::Mentor.none)
      end
    end

    context "when mentor ids are provided" do
      let(:mentor_trainings) { [mentor_training] }
      let(:attributes) { { mentor_ids: [mentor.id] } }

      it "returns mentors in full-name order" do
        expect(step.selected_mentors).to contain_exactly(mentor)
      end
    end
  end

  describe "#mentor_ids=" do
    let(:mentor_trainings) { [mentor_training] }
    let(:attributes) { { mentor_ids: [mentor.id, "", nil] } }

    it "compacts blank values" do
      expect(step.mentor_ids).to eq([mentor.id])
    end
  end
end
