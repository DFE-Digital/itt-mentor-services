require "rails_helper"

RSpec.describe "Schools", type: :request do
  describe "GET /search" do
    context "when the user is a support user", service: :claims do
      it "returns a successful response" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        get search_claims_support_schools_path

        expect(response).to have_http_status(:ok)
      end

      it "returns a list of schools matching the query" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        school1 = create(:claims_school, name: "Test School 1")
        school2 = create(:claims_school, name: "Test School 2")
        create(:claims_school, name: "Another School")

        get search_claims_support_schools_path, params: { q: "Test" }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to contain_exactly(
          { "id" => school1.id, "name" => school1.name },
          { "id" => school2.id, "name" => school2.name },
        )
      end

      it "limits the number of results to a maximum of 100" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        105.times { |i| create(:claims_school, name: "School #{i + 1}") }

        get search_claims_support_schools_path, params: { limit: 200 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(100)
      end

      it "returns a list of schools with a specified limit" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        50.times { |i| create(:claims_school, name: "School #{i + 1}") }

        get search_claims_support_schools_path, params: { limit: 25 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(25)
      end

      it "returns a list of schools with a limit and query" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        50.times { |i| create(:claims_school, name: "School #{i + 1}") }

        get search_claims_support_schools_path, params: { q: "School", limit: 25 }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(25)
      end

      it "returns an empty array when no schools match the query" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        get search_claims_support_schools_path, params: { q: "Nonexistent" }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq([])
      end

      it "returns a list of schools without a query" do
        claims_user = create(:claims_support_user)
        sign_in_as claims_user

        school1 = create(:claims_school, name: "Test School 1")
        school2 = create(:claims_school, name: "Test School 2")

        get search_claims_support_schools_path

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to contain_exactly(
          { "id" => school1.id, "name" => school1.name },
          { "id" => school2.id, "name" => school2.name },
        )
      end
    end
  end
end
