require "rails_helper"

RSpec.describe "Sessions", type: :request do
  around do |example|
    host! ENV["PLACEMENTS_HOST"]
    example.run
    host! nil
  end

  describe "POST /auth/developer/callback" do
    it "returns http success" do
      placements_user = create(:placements_user)
      post auth_developer_callback_path,
           params: {
             first_name: placements_user.first_name,
             last_name: placements_user.last_name,
             email: placements_user.email,
           }
      follow_redirect!

      expect(response).to have_http_status(:success)
      # TODO: Change render_template once redirect to service specific
      # roots implemented
      expect(response).to render_template("placements/pages/index")
    end
  end
end
