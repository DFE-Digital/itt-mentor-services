require "rails_helper"

RSpec.describe "Personas", type: :request do
  describe "GET /personas" do
    it "returns http success" do
      get personas_path
      expect(response).to have_http_status(:success)
    end
  end
end
