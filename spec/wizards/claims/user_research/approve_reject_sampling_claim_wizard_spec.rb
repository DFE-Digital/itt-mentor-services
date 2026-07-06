require "rails_helper"

RSpec.describe Claims::UserResearch::ApproveRejectSamplingClaimWizard do
  subject(:wizard) { described_class.new(claim:, current_user:, action:, state:, params:, current_step: nil) }

  let(:state) { {} }
  let(:params) { ActionController::Parameters.new }
  let(:action) { "reject" }
  let(:current_user) { create(:claims_support_user) }
  let(:provider) { create(:claims_provider) }
  let(:school) { create(:claims_school) }
  let(:mentor) { create(:claims_mentor, schools: [school]) }
  let(:claim) do
    create(:claim, :submitted, provider:, school:, status: :sampling_in_progress).tap do |created_claim|
      create(:mentor_training, claim: created_claim, mentor:, provider:, hours_completed: 6)
    end
  end

  describe "#steps" do
    let(:state) do
      {
        "mentor" => { "mentor_ids" => [mentor.id] },
      }
    end

    it "adds a mentor training step for each selected mentor" do
      expect(wizard.steps.keys).to contain_exactly(
        :mentor,
        "mentor_training_#{mentor.id}".to_sym,
        :check_your_answers,
      )
    end
  end

  describe "#process_submission" do
    context "when the wizard is invalid" do
      it "raises an invalid wizard state error" do
        expect { wizard.process_submission }.to raise_error("Invalid wizard state")
      end
    end

    context "when approving a claim" do
      let(:action) { "approve" }
      let(:state) do
        {
          "mentor" => { "mentor_ids" => [mentor.id] },
          "mentor_training_#{mentor.id}" => {
            "mentor_id" => mentor.id,
          },
        }
      end

      it "marks the claim as paid and records support activity" do
        expect {
          wizard.process_submission
        }.to change { claim.reload.status }.from("sampling_in_progress").to("paid")
          .and change(Claims::ClaimActivity, :count).by(1)

        expect(Claims::ClaimActivity.last.action).to eq("provider_approved_audit")
      end
    end

    context "when rejecting a claim" do
      let(:action) { "reject" }
      let(:state) do
        {
          "mentor" => { "mentor_ids" => [mentor.id] },
          "mentor_training_#{mentor.id}" => {
            "mentor_id" => mentor.id,
            "reason_not_assured" => "Training not completed",
            "hours_option" => "custom",
            "custom_hours" => "3",
          },
        }
      end

      it "marks the claim as provider not approved and records support activity" do
        expect {
          wizard.process_submission
        }.to change { claim.reload.status }.from("sampling_in_progress").to("sampling_provider_not_approved")
          .and change(Claims::ClaimActivity, :count).by(1)

        expect(Claims::ClaimActivity.last.action).to eq("rejected_by_provider")
      end
    end

    context "when action is unsupported" do
      let(:action) { "review" }
      let(:state) do
        {
          "mentor" => { "mentor_ids" => [mentor.id] },
          "mentor_training_#{mentor.id}" => {
            "mentor_id" => mentor.id,
          },
        }
      end

      it "does not change claim state or record activity" do
        expect {
          wizard.process_submission
        }.not_to change(Claims::ClaimActivity, :count)

        expect(claim.reload.status).to eq("sampling_in_progress")
      end
    end
  end

  describe "#academic_year" do
    it "returns the claim window academic year" do
      expect(wizard.academic_year).to eq(claim.claim_window.academic_year)
    end
  end
end
