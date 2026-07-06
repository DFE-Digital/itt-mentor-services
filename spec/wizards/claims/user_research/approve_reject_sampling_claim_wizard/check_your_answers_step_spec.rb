require "rails_helper"

RSpec.describe Claims::UserResearch::ApproveRejectSamplingClaimWizard::CheckYourAnswersStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes: nil) }

  let(:mock_wizard) do
    instance_double(
      Claims::UserResearch::ApproveRejectSamplingClaimWizard,
      claim: create(:claim),
      mentor_trainings: [],
      action:,
    )
  end

  describe "#action_heading" do
    context "when approving" do
      let(:action) { "approve" }

      it "returns approve heading text" do
        expect(step.action_heading).to eq("Approve this claim")
      end
    end

    context "when rejecting" do
      let(:action) { "reject" }

      it "returns reject heading text" do
        expect(step.action_heading).to eq("Reject this claim")
      end
    end
  end
end
