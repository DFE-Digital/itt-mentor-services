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
  end
end
