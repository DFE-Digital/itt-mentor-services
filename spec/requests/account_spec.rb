require "rails_helper"

RSpec.describe "Account", type: :request do
  describe "GET /account" do
    context "when the service is claims", service: :claims do
      it "returns http success" do
        claims_user = create(:claims_user)
        sign_in_as claims_user

        get "/account"

        expect(response).to have_http_status(:success)
        expect(response).to render_template("account/show")
      end
    end

    context "when the service is placments", service: :placements do
      it "returns http success" do
        placements_user = create(:placements_user)
        sign_in_as placements_user

        expect { get "/account" }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
