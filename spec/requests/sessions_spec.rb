require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "POST /auth/developer/callback" do
    it "returns http success" do
      claims_user = create(:claims_user)

      post "/auth/developer/callback",
           params: {
             first_name: claims_user.first_name,
             last_name: claims_user.last_name,
             email: claims_user.email,
           }

      follow_redirect!

      expect(response).to have_http_status(:success)
      # TODO: Change render_template once redirect to service specific
      # roots implemented
      expect(response).to render_template("claims/pages/index")
    end
  end
end
