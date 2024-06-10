require "rails_helper"

RSpec.describe "Support users", type: :request, service: :placements do
  let(:current_user) { create(:placements_support_user) }
  let(:support_users) { Placements::SupportUser.all }

  before do
    user_exists_in_dfe_sign_in(user: current_user)
    get "/auth/dfe/callback"
    follow_redirect!
  end

  describe "DELETE" do
    context "when deleting a support user" do
      let(:user) { create(:placements_support_user) }

      it "deletes the user" do
        expect(support_users).to include(user)
        delete placements_support_support_user_path(user)
        expect(flash[:success]).to eq "Support user removed"
        expect(support_users).not_to include(user)
      end
    end

    context "when the current user tries to delete themselves" do
      it "shows an error message" do
        delete placements_support_support_user_path(current_user)
        expect(flash[:alert]).to eq "You cannot perform this action"
        expect(support_users).to include(current_user)
      end
    end
  end
end
