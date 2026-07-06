require "rails_helper"

RSpec.describe Claims::ApproveSamplingClaimWizard do
  subject(:wizard) { described_class.new(claim:, current_user:, state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params) { ActionController::Parameters.new }
  let(:current_user) { create(:claims_support_user) }
  let(:provider) { create(:claims_provider) }
  let(:school) { create(:claims_school) }
  let(:mentor) { create(:claims_mentor, schools: [school]) }
  let(:claim) do
    create(:claim, :submitted, provider:, school:, status: :sampling_in_progress).tap do |created_claim|
      create(:mentor_training, claim: created_claim, mentor:, provider:, hours_completed: 6, training_type: :refresher)
    end
  end

  describe "#steps" do
    context "when mentors are selected" do
      let(:state) do
        {
          "mentor" => { "mentor_ids" => [mentor.id] },
        }
      end

      it "builds mentor training steps for selected mentors" do
        expect(wizard.steps.keys).to contain_exactly(
          :mentor,
          "mentor_training_#{mentor.id}".to_sym,
          :check_your_answers,
        )
      end
    end
  end

  describe "#approve_claim" do
    context "when the wizard is invalid" do
      it "raises an invalid wizard state error" do
        expect { wizard.approve_claim }.to raise_error("Invalid wizard state")
      end
    end

    context "when the wizard is valid" do
      let(:state) do
        {
          "mentor" => { "mentor_ids" => [mentor.id] },
          "mentor_training_#{mentor.id}" => {
            "mentor_id" => mentor.id,
            "hours_completed" => 6,
          },
        }
      end

      it "marks the claim as paid and records claim activity" do
        expect {
          wizard.approve_claim
        }.to change { claim.reload.status }.from("sampling_in_progress").to("paid")
          .and change(Claims::ClaimActivity, :count).by(1)

        activity = Claims::ClaimActivity.last
        expect(activity.action).to eq("provider_approved_audit")
        expect(activity.user).to eq(current_user)
        expect(activity.record).to eq(claim)
      end
    end
  end
end
