require "rails_helper"

RSpec.describe "Approve a clawback", service: :claims, type: :request do
  let(:support_user) { create(:claims_support_user) }
  let(:status) { :clawback_requires_approval }
  let(:claim) { create(:claim, :submitted, status:) }

  before { sign_in_as support_user }

  describe "GET approval" do
    it "shows the review page" do
      get "/support/claims/clawbacks/claims/#{claim.id}/approval"

      expect(response).to have_http_status(:ok)
    end

    context "when the claim does not require approval" do
      let(:status) { :clawback_requested }

      it "does not show the review page" do
        get "/support/claims/clawbacks/claims/#{claim.id}/approval"

        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "POST approval" do
    it "approves the clawback" do
      post "/support/claims/clawbacks/claims/#{claim.id}/approval"

      expect(response).to redirect_to("/support/claims/clawbacks/claims/#{claim.id}")
      expect(claim.reload).to have_attributes(status: "clawback_requested", clawback_approved_by: support_user)
    end

    context "when the claim does not require approval" do
      let(:status) { :clawback_requested }

      it "does not change the claim" do
        post "/support/claims/clawbacks/claims/#{claim.id}/approval"

        expect(claim.reload.clawback_approved_by).to be_nil
      end
    end

    context "when the user is not a support user" do
      let(:support_user) { create(:claims_user) }

      it "does not change the claim" do
        post "/support/claims/clawbacks/claims/#{claim.id}/approval"

        expect(claim.reload.status).to eq("clawback_requires_approval")
      end
    end
  end
end
