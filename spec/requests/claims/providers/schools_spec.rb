require "rails_helper"

RSpec.describe "Provider schools", service: :claims, type: :request do
  let(:provider) { create(:claims_provider, name: "North Star SCITT") }
  let(:other_provider) { create(:claims_provider, name: "Other Provider") }
  let(:provider_user) { create(:claims_provider_user) }

  let(:riverbank) { create(:claims_school, name: "Riverbank Primary") }
  let(:hilltop) { create(:claims_school, name: "Hilltop Secondary") }
  let(:draft_school) { create(:claims_school, name: "Draftwood Academy") }
  let(:other_provider_school) { create(:claims_school, name: "Riverside College") }

  before do
    provider.users << provider_user

    create(:claim, :submitted, provider:, school: riverbank)
    create(:claim, :submitted, provider:, school: hilltop)
    create(:claim, :draft, provider:, school: draft_school)
    create(:claim, :submitted, provider: other_provider, school: other_provider_school)
  end

  describe "GET /providers/:provider_id/schools/search" do
    context "when the user is a provider user of the provider" do
      before { sign_in_as provider_user }

      it "returns the schools with non draft claims for the provider, ordered by name" do
        get claims_provider_schools_search_path(provider)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq(
          [
            { "id" => hilltop.id, "name" => hilltop.name },
            { "id" => riverbank.id, "name" => riverbank.name },
          ],
        )
      end

      it "excludes schools which only have draft claims" do
        get claims_provider_schools_search_path(provider)

        expect(response.parsed_body.pluck("name")).not_to include(draft_school.name)
      end

      it "excludes schools which only have claims for another provider" do
        get claims_provider_schools_search_path(provider)

        expect(response.parsed_body.pluck("name")).not_to include(other_provider_school.name)
      end

      it "filters the schools by the given query" do
        get claims_provider_schools_search_path(provider), params: { q: "river" }

        expect(response.parsed_body).to eq([{ "id" => riverbank.id, "name" => riverbank.name }])
      end

      it "returns an empty array when no schools match the query" do
        get claims_provider_schools_search_path(provider), params: { q: "Nonexistent" }

        expect(response.parsed_body).to eq([])
      end

      it "returns each school once when a school has multiple claims" do
        create(:claim, :submitted, provider:, school: riverbank)

        get claims_provider_schools_search_path(provider), params: { q: "Riverbank" }

        expect(response.parsed_body).to eq([{ "id" => riverbank.id, "name" => riverbank.name }])
      end

      it "clamps the limit to a minimum of 25" do
        30.times { |index| create(:claim, :submitted, provider:, school: create(:claims_school, name: "School #{index}")) }

        get claims_provider_schools_search_path(provider), params: { limit: 1 }

        expect(response.parsed_body.size).to eq(25)
      end

      it "clamps the limit to a maximum of 100" do
        105.times { |index| create(:claim, :submitted, provider:, school: create(:claims_school, name: "School #{index}")) }

        get claims_provider_schools_search_path(provider), params: { limit: 200 }

        expect(response.parsed_body.size).to eq(100)
      end
    end

    context "when the user is a support user" do
      before { sign_in_as create(:claims_support_user) }

      it "returns the schools with non draft claims for the provider" do
        get claims_provider_schools_search_path(provider)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.pluck("name")).to contain_exactly(hilltop.name, riverbank.name)
      end
    end

    context "when the user does not belong to the provider" do
      before { sign_in_as create(:claims_provider_user) }

      it "does not return the provider schools" do
        expect { get claims_provider_schools_search_path(provider) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
