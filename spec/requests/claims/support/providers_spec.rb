require "rails_helper"

RSpec.describe "Providers", type: :request do
  describe "GET /search" do
    let(:search_path) { search_claims_support_providers_path }

    context "when the user is a support user", service: :claims do
      it "returns a successful response" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        get search_path

        expect(response).to have_http_status(:ok)
      end

      it "returns a list of providers matching the query" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        provider1 = create(:claims_provider, name: "Test Provider 1")
        provider2 = create(:claims_provider, name: "Test Provider 2")
        create(:claims_provider, name: "Another Provider")

        get search_path, params: { q: "Test" }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to contain_exactly(
          { "id" => provider1.id, "name" => provider1.name },
          { "id" => provider2.id, "name" => provider2.name },
        )
      end

      it "limits the number of results to a maximum of 100" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        105.times { |i| create(:claims_provider, name: "Provider #{i + 1}") }

        get search_path, params: { limit: 200 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(100)
      end

      it "returns a list of providers with a specified limit" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        50.times { |i| create(:claims_provider, name: "Provider #{i + 1}") }

        get search_path, params: { limit: 25 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(25)
      end

      it "returns a list of providers with a limit and query" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        50.times { |i| create(:claims_provider, name: "Provider #{i + 1}") }

        get search_path, params: { q: "Provider", limit: 25 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(25)
      end

      it "returns an empty array when no providers match the query" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        get search_path, params: { q: "Nonexistent" }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq([])
      end

      it "returns a list of providers without a query" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        provider1 = create(:claims_provider, name: "Test Provider 1")
        provider2 = create(:claims_provider, name: "Test Provider 2")

        get search_path

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to contain_exactly(
          { "id" => provider1.id, "name" => provider1.name },
          { "id" => provider2.id, "name" => provider2.name },
        )
      end

      it "returns only accredited providers" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        provider1 = create(:claims_provider, name: "Test Provider 1")
        _provider2 = create(:claims_provider, name: "Test Provider 2", accredited: false)

        get search_path

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to contain_exactly(
          { "id" => provider1.id, "name" => provider1.name },
        )
      end

      it "returns only NIoT headquarters" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        niot_headquarters = create(:claims_provider, code: "2N2", name: "NIoT")
        _niot_site_1 = create(:claims_provider, code: "1YF", name: "NIoT")
        _niot_site_2 = create(:claims_provider, code: "21J", name: "NIoT")

        get search_path

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to contain_exactly(
          { "id" => niot_headquarters.id, "name" => niot_headquarters.name },
        )
      end
    end
  end
end
