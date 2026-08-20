require "rails_helper"

RSpec.describe "Providers", service: :claims, type: :request do
  describe "GET /providers" do
    context "when the provider user belongs to one provider" do
      let(:provider) { create(:claims_provider) }
      let(:provider_user) { create(:claims_provider_user) }

      before do
        provider.users << provider_user
        sign_in_as provider_user
      end

      it "redirects to the claims for that provider" do
        get claims_providers_path

        expect(response).to redirect_to(claims_provider_claims_path(provider))
      end
    end

    context "when the provider user belongs to more than one provider" do
      let(:provider) { create(:claims_provider, name: "North Star SCITT") }
      let(:other_provider) { create(:claims_provider, name: "Other Provider") }
      let(:provider_user) { create(:claims_provider_user) }

      before do
        provider.users << provider_user
        other_provider.users << provider_user
        sign_in_as provider_user
      end

      it "renders the list of providers without redirecting" do
        get claims_providers_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(provider.name)
        expect(response.body).to include(other_provider.name)
      end
    end

    context "when the provider user belongs to no providers" do
      before { sign_in_as create(:claims_provider_user) }

      it "renders the list of providers without redirecting" do
        get claims_providers_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user is a support user" do
      before do
        create_list(:claims_provider, 2)
        sign_in_as create(:claims_support_user)
      end

      it "renders the list of providers without redirecting" do
        get claims_providers_path

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user is a support user and only one provider exists" do
      let!(:provider) { create(:claims_provider) }

      before { sign_in_as create(:claims_support_user) }

      it "redirects to the claims for that provider" do
        get claims_providers_path

        expect(response).to redirect_to(claims_provider_claims_path(provider))
      end
    end
  end
end
