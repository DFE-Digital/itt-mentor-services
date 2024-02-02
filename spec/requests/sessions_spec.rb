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
end
