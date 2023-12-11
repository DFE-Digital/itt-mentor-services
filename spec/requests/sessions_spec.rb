require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "POST /auth/developer/callback" do
    it "returns http success" do
      post auth_developer_callback_path, params: {
        first_name: "Anne", 
        last_name: "Wilson",
        email: "anne_wilson@example.com"
      }
      follow_redirect!

      expect(response).to have_http_status(:success)
      # TODO: Change render_template once redirect to service specific
      # roots implemented
      expect(response).to render_template("pages/home")
    end
  end
end