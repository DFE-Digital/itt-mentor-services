require "rails_helper"

RSpec.describe "Provider sampling claims approval/rejection wizard", type: :request do
  let(:provider) { create(:claims_provider, name: "Test provider", code: "TEST01") }
  let(:school) { create(:claims_school) }
  let(:mentor1) { create(:claims_mentor, schools: [school]) }
  let(:mentor2) { create(:claims_mentor, schools: [school]) }

  let(:claim) do
    create(:claim,
      :submitted,
      provider:,
      school:,
      status: "sampling_in_progress",
      mentor_trainings: [
        build(:mentor_training, mentor: mentor1, hours_completed: 10),
        build(:mentor_training, mentor: mentor2, hours_completed: 15),
      ])
  end

  before do
    post claims_user_research_provider_session_path, params: {
      provider_code: "BPN01",
      email: "research+test-provider@example.org",
    }
  end

  describe "GET /user-research/provider/claims/:id/approve_claim/new", service: :claims do
    it "renders the approve confirmation page" do
      get new_approve_claim_claims_user_research_provider_claim_path(claim)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Are you sure you want to approve this claim?")
    end
  end

  describe "GET /user-research/provider/claims/:id/reject_claim/new", service: :claims do
    it "redirects to the first reject wizard step" do
      get new_reject_claim_claims_user_research_provider_claim_path(claim)

      expect(response).to redirect_to(/reject_claim\/new\/.*\/mentor/)
    end
  end

  describe "Approve flow", service: :claims do
    it "marks the claim as paid and redirects to the index with a success message" do
      post approve_claim_claims_user_research_provider_claim_path(claim)

      expect(response).to redirect_to(claims_user_research_provider_claims_path)
      follow_redirect!
      expect(response.body).to include("Claim approved")
      expect(claim.reload.status).to eq("paid")
    end
  end

  describe "Reject wizard flow", service: :claims do
    it "guides through mentor selection, hours and reason confirmation, and rejection" do
      # Step 1: Select mentors
      get reject_claim_claims_user_research_provider_claim_path(
        claim,
        state_key: "rejecting_#{claim.id}",
        step: :mentor,
      )

      expect(response).to have_http_status(:ok)

      put reject_claim_claims_user_research_provider_claim_path(
        claim,
        state_key: "rejecting_#{claim.id}",
        step: :mentor,
      ), params: {
        claims_user_research_approve_reject_sampling_claim_wizard_mentor_step: {
          mentor_ids: [mentor1.id],
        },
      }

      expect(response).to redirect_to(/reject_claim.*mentor_training/)

      # Step 2: Confirm hours and provide rejection reason
      follow_redirect!

      put response.request.path, params: {
        claims_user_research_approve_reject_sampling_claim_wizard_mentor_training_step: {
          mentor_id: mentor1.id,
          hours_completed: "8",
          reason_not_assured: "Insufficient evidence provided for claimed hours",
        },
      }

      expect(response).to redirect_to(/reject_claim.*check_your_answers/)

      # Step 3: Review and reject
      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Reject this claim")

      put response.request.path, params: {}

      expect(response).to redirect_to(claims_user_research_provider_claims_path)

      expect(claim.reload.status).to eq("sampling_provider_not_approved")
    end

    it "requires a rejection reason" do
      state_key = "rejecting_#{claim.id}"

      put reject_claim_claims_user_research_provider_claim_path(
        claim,
        state_key:,
        step: :mentor,
      ), params: {
        claims_user_research_approve_reject_sampling_claim_wizard_mentor_step: {
          mentor_ids: [mentor1.id],
        },
      }

      follow_redirect!

      put response.request.path, params: {
        claims_user_research_approve_reject_sampling_claim_wizard_mentor_training_step: {
          mentor_id: mentor1.id,
          hours_completed: "8",
          reason_not_assured: "",
        },
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("There is a problem")
      expect(response.body).to include("Please enter a reason")
    end
  end

  describe "Show page approve/reject buttons", service: :claims do
    it "displays approve and reject buttons for sampling_in_progress claims" do
      get claims_user_research_provider_claim_path(claim)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Approve claim")
      expect(response.body).to include("Reject claim")
    end

    it "does not display buttons for non-sampling claims" do
      submitted_claim = create(:claim, :submitted, provider:, school:)

      get claims_user_research_provider_claim_path(submitted_claim)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("Approve claim")
      expect(response.body).not_to include("Reject claim")
    end
  end
end
