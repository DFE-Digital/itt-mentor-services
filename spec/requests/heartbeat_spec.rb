require "rails_helper"

RSpec.describe "Heartbeats", type: :request do
  describe "GET /healthcheck" do
    before do
      allow(ActiveRecord::Base.connection).to receive(:active?).and_return(true)
    end

    context "when everything is ok" do
      it "returns HTTP success" do
        get "/healthcheck"

        expect(response).to have_http_status :ok
      end

      it "returns the expected response report" do
        get "/healthcheck"

        expect(response.body).to eq({ checks: { database: true } }.to_json)
      end
    end

    context "when there's no db connection" do
      before do
        allow(ActiveRecord::Base).to receive(:connected?).and_return(false)
      end

      it("returns 503") do
        get "/healthcheck"

        expect(response).to have_http_status :service_unavailable
      end
    end
  end
end
