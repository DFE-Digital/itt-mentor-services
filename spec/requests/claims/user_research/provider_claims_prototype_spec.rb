require "rails_helper"

RSpec.describe "Provider claims user research prototype", type: :request do
  let(:provider) { create(:claims_provider, name: "Test provider", code: "TEST01") }
  let(:other_provider) { create(:claims_provider) }

  describe "POST /user-research/provider-session", service: :claims do
    it "signs in with valid prototype credentials" do
      post claims_user_research_provider_session_path, params: {
        provider_code: "BPN01",
        email: "research+test-provider@example.org",
      }

      expect(response).to redirect_to(claims_user_research_provider_claims_path)
    end

    it "shows an error with invalid prototype credentials" do
      post claims_user_research_provider_session_path, params: {
        provider_code: "BPN01",
        email: "not-valid@example.org",
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("There is a problem")
    end
  end

  describe "GET /user-research/provider/claims", service: :claims do
    it "redirects back to the claims landing page if no provider session exists" do
      get claims_user_research_provider_claims_path

      expect(response).to redirect_to(claims_root_path)
    end

    it "shows support-style filters and cards scoped to the signed-in provider" do
      visible_claim = create(:claim, :submitted, provider:)
      visible_paid_claim = create(:claim, :submitted, provider:, status: "paid")
      visible_audit_requested_claim = create(:claim, :submitted, provider:, status: "sampling_in_progress")
      hidden_claim_in_other_status = create(:claim, :submitted, provider:, status: "payment_in_progress")
      hidden_claim = create(:claim, :submitted, provider: other_provider)

      post claims_user_research_provider_session_path, params: {
        provider_code: "BPN01",
        email: "research+test-provider@example.org",
      }

      get claims_user_research_provider_claims_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Apply filters")
      expect(response.body).not_to include("Accredited provider")
      expect(response.body).not_to include("Support user")
      expect(response.body).not_to include("Submitted after")
      expect(response.body).not_to include("Submitted before")
      expect(response.body).to include("Submitted")
      expect(response.body).to include("Paid")
      expect(response.body).to include("Rejected by provider")
      expect(response.body).to include("Audit requested")
      expect(response.body).not_to include("Payer payment review")
      expect(response.body).not_to include("Payer needs information")
      expect(response.body).to include(visible_claim.reference)
      expect(response.body).to include(visible_paid_claim.reference)
      expect(response.body).to include(visible_audit_requested_claim.reference)
      expect(response.body).not_to include(hidden_claim_in_other_status.reference)
      expect(response.body).not_to include(hidden_claim.reference)
    end

    it "renders a reset demo data button" do
      post claims_user_research_provider_session_path, params: {
        provider_code: "BPN01",
        email: "research+test-provider@example.org",
      }

      get claims_user_research_provider_claims_path

      expect(response.body).to include("Reset demo data")
    end

    it "resets the demo data back to the initial claims set" do
      school = create(:claims_school)
      create(:claims_mentor, schools: [school])
      create(:claim, :submitted, provider:, school:)

      post claims_user_research_provider_session_path, params: {
        provider_code: "BPN01",
        email: "research+test-provider@example.org",
      }

      post reset_demo_claims_user_research_provider_claims_path

      demo_provider = Claims::Provider.find_by!(code: "TEST01")
      demo_claims = Claims::Claim.where(provider: demo_provider)

      expect(response).to redirect_to(claims_user_research_provider_claims_path)
      expect(demo_provider.name).to eq("Test provider")
      expect(demo_claims.count).to eq(12)
      expect(demo_claims.pluck(:status)).to contain_exactly(
        "sampling_in_progress",
        "sampling_in_progress",
        "sampling_provider_not_approved",
        "sampling_provider_not_approved",
        "submitted",
        "submitted",
        "paid",
        "paid",
        "paid",
        "paid",
        "paid",
        "paid",
      )
      expect(demo_claims.map { |claim| claim.academic_year.id }.uniq.count).to eq(3)
      expect(demo_claims.map(&:claim_window_id).uniq.count).to eq(6)
      expect(demo_claims.joins(:mentor_trainings).pluck("mentor_trainings.training_type").uniq)
        .to contain_exactly("initial", "refresher")
    end
  end

  describe "GET /user-research/provider/claims/:id", service: :claims do
    it "shows a claim from the signed-in provider" do
      claim = create(:claim, :submitted, provider:)

      post claims_user_research_provider_session_path, params: {
        provider_code: "BPN01",
        email: "research+test-provider@example.org",
      }

      get claims_user_research_provider_claim_path(claim)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Claim reference")
      expect(response.body).to include(claim.reference)
    end

    it "returns not found for a claim outside the provider session" do
      claim = create(:claim, :submitted, provider: other_provider)

      post claims_user_research_provider_session_path, params: {
        provider_code: "BPN01",
        email: "research+test-provider@example.org",
      }

      get claims_user_research_provider_claim_path(claim)

      expect(response).to have_http_status(:not_found)
    end
  end
end
