require "rails_helper"

RSpec.describe "Personas", type: :request do
  describe "GET /personas" do
    around do |example|
      original_sign_in_method = ENV["SIGN_IN_METHOD"]

      ClimateControl.modify SIGN_IN_METHOD: "persona" do
        Rails.application.reload_routes!
        example.run
      end

      ClimateControl.modify SIGN_IN_METHOD: original_sign_in_method do
        Rails.application.reload_routes!
      end
    end

    it "returns http success" do
      get "/personas"
      expect(response).to have_http_status(:success)
    end

    context "when claims service", service: :claims do
      it "shows a persona with both a school and a provider record only once" do
        create(:claims_user, :mary)
        create(:claims_provider_user, :mary)

        get "/personas"

        expect(response.body.scan("Sign in as Mary").size).to eq(1)
      end
    end

    context "when placements service", service: :placements do
      it "returns http success" do
        get "/personas"
        expect(response).to have_http_status(:success)
      end
    end
  end
end
