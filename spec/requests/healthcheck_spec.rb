require "rails_helper"

RSpec.describe "Healthcheck", type: :request do
  describe "GET /healthcheck" do
    context "when everything is ok" do
      it "returns HTTP success" do
        get "/healthcheck"

        expect(response).to have_http_status :ok
      end
    end
  end
end
