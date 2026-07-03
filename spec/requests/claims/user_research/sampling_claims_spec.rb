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
    it "renders the approve confirmation page with school name caption and no Provider prototype text" do
      get new_approve_claim_claims_user_research_provider_claim_path(claim)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(school.name)
      expect(response.body).not_to include("Provider prototype")
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

      expect(response.body).to include(school.name)
      expect(response.body).to include("How many hours did #{mentor1.full_name} actually complete?")
      expect(response.body).to include("Enter the training hours the mentor completed")
      expect(response.body).not_to include("TRN")

      put response.request.path, params: {
        claims_user_research_approve_reject_sampling_claim_wizard_mentor_training_step: {
          mentor_id: mentor1.id,
          hours_option: "custom",
          custom_hours: "8",
          reason_not_assured: "Insufficient evidence provided for claimed hours",
        },
      }

      expect(response).to redirect_to(/reject_claim.*check_your_answers/)

      # Step 3: Review and reject
      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mentor hours to amend")
      expect(response.body).to include("Hours originally claimed")
      expect(response.body).to include("Hours mentor completed training")

      expect(response.body).to include("Amend this claim")
      expect(response.body).to include("status will be updated to")
      expect(response.body).to include("Amended")

      put response.request.path, params: {}

      expect(response).to redirect_to(claims_user_research_provider_claims_path)

      expect(claim.reload.status).to eq("sampling_provider_not_approved")
      expect(claim.mentor_trainings.find_by(mentor_id: mentor1.id)&.hours_clawed_back).to eq(2)
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
           hours_option: "custom",
           custom_hours: "8",
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
      expect(response.body).to include("Amend claim")
    end

    it "does not display buttons for non-sampling claims" do
      submitted_claim = create(:claim, :submitted, provider:, school:)

      get claims_user_research_provider_claim_path(submitted_claim)

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("Approve claim")
      expect(response.body).not_to include("Amend claim")
    end
  end

  describe "Show page amended mentor summary", service: :claims do
    let(:mentor) { mentor1 }

    let(:amended_claim) do
      create(:claim,
        :submitted,
        provider:,
        school:,
        status: "sampling_provider_not_approved",
        mentor_trainings: [
          build(:mentor_training,
            mentor:,
            hours_completed: 10,
            hours_clawed_back: 3,
            not_assured: true,
            reason_not_assured: "Only 7 hours of evidence provided"),
        ])
    end

    before do
      get claims_user_research_provider_claim_path(amended_claim)
    end

    it "shows the amended mentor summary section with completed-training labels" do
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mentors with amended hours")
      expect(response.body).to include("Hours originally claimed")
      expect(response.body).to include("Training hours mentor completed")
      expect(response.body).to include("Hours removed from claim")
      expect(response.body).to include("Reason for amendment")
      expect(response.body).to include("Only 7 hours of evidence provided")
      expect(response.body).not_to include("Mentors with worked hours")
      expect(response.body).not_to include("Hours mentor actually worked")
    end
  end
end
