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

    it "signs a first time user in as their own record without merging other users" do
      school = create(:claims_school)
      other_school = create(:claims_school)
      new_user = create(:claims_user, email: "anne@example.com", dfe_sign_in_uid: nil, last_signed_in_at: nil)
      other_user = create(:claims_user, email: "bob@example.com", dfe_sign_in_uid: "bob-uid")
      create(:user_membership, user: new_user, organisation: school)
      create(:user_membership, user: other_user, organisation: other_school)
      user_exists_in_dfe_sign_in(user: build(:claims_user, email: "anne@example.com", dfe_sign_in_uid: "anne-uid"))

      get "/auth/dfe/callback"

      expect(new_user.reload).to have_attributes(dfe_sign_in_uid: "anne-uid", schools: [school])
      expect(other_user.reload).to have_attributes(dfe_sign_in_uid: "bob-uid", schools: [other_school])
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
