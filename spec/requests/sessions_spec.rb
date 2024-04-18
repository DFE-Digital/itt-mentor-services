require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "GET /auth/dfe/callback" do
    it "returns http success" do
      claims_user = create(:claims_user)
      user_exists_in_dfe_sign_in(user: claims_user)

      get "/auth/dfe/callback"

      follow_redirect!

      expect(response).to have_http_status(:success)
      # TODO: Change render_template once redirect to service specific
      # roots implemented
      expect(response).to render_template("claims/schools/index")
    end
  end

  describe "GET /auth/failure" do
    it "returns http internal_server_error" do
      allow(Sentry).to receive(:capture_message)

      get "/auth/failure"
      follow_redirect!

      expect(response).to have_http_status(:internal_server_error)
      expect(Sentry).to have_received(:capture_message)
    end
  end
end
