require "rails_helper"

RSpec.describe "Provider claims download", service: :claims, type: :request do
  let(:provider) { create(:claims_provider, name: "North Star SCITT") }
  let(:second_provider) { create(:claims_provider, name: "South Star SCITT") }
  let(:other_provider) { create(:claims_provider, name: "Other provider") }
  let(:provider_user) { create(:claims_provider_user, :patricia, providers: [provider, second_provider]) }
  let(:school) { create(:claims_school) }
  let(:mentor) { create(:claims_mentor, schools: [school]) }

  let!(:claim) { create_claim(provider:) }
  let!(:second_provider_claim) { create_claim(provider: second_provider) }
  let!(:other_provider_claim) { create_claim(provider: other_provider) }
  let!(:draft_claim) { create_claim(provider:, status: :draft) }

  describe "GET /providers/:provider_id/claims/download" do
    context "when signed in as a provider user" do
      before { sign_in_as provider_user }

      it "downloads a CSV of claims for only the given provider, suffixed with today's date", freeze: "28 September 2026" do
        get claims_provider_claims_download_path(provider)

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/csv")
        expect(response.headers["Content-Disposition"]).to include(
          'attachment; filename="claims_funding_for_mentor_training_claims_2026-09-28.csv"',
        )
        expect(response.body).to include(claim.reference)
        expect(response.body).not_to include(second_provider_claim.reference)
        expect(response.body).not_to include(other_provider_claim.reference)
        expect(response.body).not_to include(draft_claim.reference)
      end

      it "does not allow downloading claims for a provider the user does not belong to" do
        expect {
          get claims_provider_claims_download_path(other_provider)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when signed in as a support user" do
      before { sign_in_as create(:claims_support_user) }

      it "is not permitted" do
        get claims_provider_claims_download_path(provider)

        expect(response).to have_http_status(:redirect)
        expect(response.media_type).not_to eq("text/csv")
      end
    end

    context "when signed in as a school user" do
      before { sign_in_as create(:claims_user) }

      it "is not permitted" do
        get claims_provider_claims_download_path(provider)

        expect(response).to redirect_to(sign_in_path)
      end
    end
  end

  private

  def create_claim(provider:, status: :paid)
    create(
      :claim,
      :submitted,
      status:,
      provider:,
      school:,
      mentor_trainings: [build(:mentor_training, mentor:, provider:, hours_completed: 1)],
    )
  end
end
