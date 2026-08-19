require "rails_helper"

RSpec.describe "Provider claims", type: :request, service: :claims do
  let(:provider) { create(:claims_provider, name: "Test provider") }
  let(:other_provider) { create(:claims_provider, name: "Other provider") }
  let(:provider_user) { create(:claims_provider_user, :patricia) }
  let(:school) { create(:claims_school) }
  let(:mentor1) { create(:claims_mentor, schools: [school]) }
  let(:mentor2) { create(:claims_mentor, schools: [school]) }

  let(:claim) do
    create(
      :claim,
      :submitted,
      provider:,
      school:,
      status: "sampling_in_progress",
      mentor_trainings: [
        build(:mentor_training, mentor: mentor1, provider:, hours_completed: 10),
        build(:mentor_training, mentor: mentor2, provider:, hours_completed: 15),
      ],
    )
  end

  before do
    provider.users << provider_user
    sign_in_as provider_user
  end

  describe "GET /providers/:provider_id/claims/:id" do
    it "shows the prototype-style claim details and action buttons for sampling claims" do
      get claims_provider_claim_path(provider, claim)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(school.name)
      expect(response.body).to include("Claim reference #{claim.reference}")
      expect(response.body).to include("Academic year")
      expect(response.body).to include("Approve claim")
      expect(response.body).to include("Amend claim")
      expect(response.body).to include("Hours claimed")
    end

    it "returns not found for claims belonging to another provider" do
      other_claim = create(:claim, :submitted, provider: other_provider)

      expect {
        get claims_provider_claim_path(provider, other_claim)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET /providers/:provider_id/claims/:id/approve/new" do
    it "renders the approval confirmation page" do
      get new_approve_claims_provider_claim_path(provider, claim)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(school.name)
      expect(response.body).to include("Are you sure you want to approve this claim?")
    end
  end

  describe "POST /providers/:provider_id/claims/:id/approve" do
    it "marks the claim as paid and redirects to the provider claims index" do
      post approve_claims_provider_claim_path(provider, claim)

      expect(response).to redirect_to(claims_provider_claims_path(provider))
      follow_redirect!
      expect(response.body).to include("Claim approved")
      expect(claim.reload.status).to eq("paid")
    end
  end

  describe "GET /providers/:provider_id/claims/:id/reject/new" do
    it "redirects to the first wizard step" do
      get new_reject_claims_provider_claim_path(provider, claim)

      expect(response).to redirect_to(/reject\/new\/.*\/mentor/)
    end
  end

  describe "Reject wizard flow" do
    it "guides the provider through mentor selection, amended hours, and confirmation" do
      get reject_claims_provider_claim_path(
        provider,
        claim,
        state_key: "rejecting_#{claim.id}",
        step: :mentor,
      )

      expect(response).to have_http_status(:ok)

      put reject_claims_provider_claim_path(
        provider,
        claim,
        state_key: "rejecting_#{claim.id}",
        step: :mentor,
      ), params: {
        claims_providers_approve_reject_sampling_claim_wizard_mentor_step: {
          mentor_ids: [mentor1.id],
        },
      }

      expect(response).to redirect_to(/reject.*mentor_training/)

      follow_redirect!

      expect(response.body).to include(school.name)
      expect(response.body).to include("How many hours of training did #{mentor1.full_name} actually complete?")
      expect(response.body).to include("Hours of training originally claimed: 10")

      put response.request.path, params: {
        claims_providers_approve_reject_sampling_claim_wizard_mentor_training_step: {
          mentor_id: mentor1.id,
          hours_option: "custom",
          custom_hours: "8",
          reason_not_assured: "Insufficient evidence provided for claimed hours",
        },
      }

      expect(response).to redirect_to(/reject.*check_your_answers/)

      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Hours of training to amend")
      expect(response.body).to include("Amend this claim")
      expect(response.body).to include("Amended")

      put response.request.path, params: {}

      expect(response).to redirect_to(claims_provider_claims_path(provider))
      expect(claim.reload.status).to eq("sampling_provider_not_approved")
      expect(claim.mentor_trainings.find_by(mentor_id: mentor1.id)&.hours_clawed_back).to eq(2)
    end

    it "requires a reason for the amendment" do
      state_key = "rejecting_#{claim.id}"

      put reject_claims_provider_claim_path(provider, claim, state_key:, step: :mentor), params: {
        claims_providers_approve_reject_sampling_claim_wizard_mentor_step: {
          mentor_ids: [mentor1.id],
        },
      }

      follow_redirect!

      put response.request.path, params: {
        claims_providers_approve_reject_sampling_claim_wizard_mentor_training_step: {
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

  describe "amended claim details" do
    let(:amended_claim) do
      create(
        :claim,
        :submitted,
        provider:,
        school:,
        status: "sampling_provider_not_approved",
        mentor_trainings: [
          build(
            :mentor_training,
            mentor: mentor1,
            provider:,
            hours_completed: 10,
            hours_clawed_back: 3,
            not_assured: true,
            reason_not_assured: "Only 7 hours of evidence provided",
          ),
        ],
      )
    end

    it "shows the amended mentor summary" do
      get claims_provider_claim_path(provider, amended_claim)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mentors with amended hours")
      expect(response.body).to include("Hours originally claimed")
      expect(response.body).to include("Training hours mentor completed")
      expect(response.body).to include("Hours removed from claim")
      expect(response.body).to include("Reason for amendment")
      expect(response.body).to include("Only 7 hours of evidence provided")
    end
  end
end
