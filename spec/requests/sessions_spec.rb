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

    it "merges unused school and provider records for a user with both" do
      school = create(:claims_school)
      provider = create(:claims_provider)
      school_user = create(:claims_user, email: "anne.old@example.com", dfe_sign_in_uid: "anne-uid")
      provider_user = create(:claims_provider_user, email: "anne.old@example.com", dfe_sign_in_uid: "anne-uid")
      unused_school_user = create(:claims_user, email: "anne.new@example.com", dfe_sign_in_uid: nil, last_signed_in_at: nil)
      unused_provider_user = create(:claims_provider_user, email: "anne.new@example.com", dfe_sign_in_uid: nil, last_signed_in_at: nil)
      create(:user_membership, user: unused_school_user, organisation: school)
      create(:user_membership, user: unused_provider_user, organisation: provider)
      user_exists_in_dfe_sign_in(user: build(:claims_user, email: "anne.new@example.com", dfe_sign_in_uid: "anne-uid"))

      get "/auth/dfe/callback"

      expect(school_user.reload.schools).to contain_exactly(school)
      expect(provider_user.reload.providers).to contain_exactly(provider)
      expect(User.unscoped.where(id: [unused_school_user.id, unused_provider_user.id])).to be_empty
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
