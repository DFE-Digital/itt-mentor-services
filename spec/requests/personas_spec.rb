require "rails_helper"

RSpec.describe "Personas", type: :request do
  context "placements" do
    describe "GET /personas" do
      around do |example|
        host! ENV["PLACEMENTS_HOST"]
        example.run
        host! nil
      end

      it "returns http success" do
        get personas_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "claims" do
    describe "GET /personas" do
      around do |example|
        host! ENV["CLAIMS_HOST"]
        example.run
        host! nil
      end

      it "returns http success" do
        get personas_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
