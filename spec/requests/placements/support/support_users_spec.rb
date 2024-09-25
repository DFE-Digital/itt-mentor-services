require "rails_helper"

RSpec.describe "Support users", service: :placements, type: :request do
  let(:current_user) { create(:placements_support_user) }
  let(:support_users) { Placements::SupportUser.all }

  before do
    sign_in_as current_user
  end

  describe "DELETE" do
    context "when deleting a support user" do
      let(:user) { create(:placements_support_user) }

      it "deletes the user" do
        expect(support_users).to include(user)
        delete placements_support_support_user_path(user)
        expect(flash[:heading]).to eq "Support user removed"

        expect(support_users).not_to include(user)
      end
    end

    context "when the current user tries to delete themselves" do
      it "shows an error message" do
        delete placements_support_support_user_path(current_user)
        expect(flash[:heading]).to eq "You cannot perform this action"
        expect(flash[:success]).to be false
        expect(support_users).to include(current_user)
      end
    end
  end
end
