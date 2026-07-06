require "rails_helper"

RSpec.describe Claims::UserResearch::ApproveRejectSamplingClaimWizard::MentorStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:attributes) { nil }
  let(:claim) { create(:claim) }
  let(:mentor) { create(:claims_mentor) }
  let(:mentor_training) { create(:mentor_training, claim:, mentor:) }
  let(:mock_wizard) { instance_double(Claims::UserResearch::ApproveRejectSamplingClaimWizard, mentor_trainings:) }

  describe "#selected_mentors" do
    context "when there are no mentor trainings" do
      let(:mentor_trainings) { [] }

      it "returns an empty relation" do
        expect(step.selected_mentors).to eq(Claims::Mentor.none)
      end
    end

    context "when mentor ids are supplied" do
      let(:mentor_trainings) { [mentor_training] }
      let(:attributes) { { mentor_ids: [mentor.id] } }

      it "returns selected mentors" do
        expect(step.selected_mentors).to contain_exactly(mentor)
      end
    end
  end
end
