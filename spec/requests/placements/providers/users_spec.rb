require "rails_helper"

RSpec.describe "Provider users", service: :placements, type: :request do
  let(:provider) { build(:placements_provider) }
  let(:current_user) { create(:placements_user, providers: [provider]) }

  before do
    sign_in_as current_user
  end

  describe "DELETE" do
    let(:provider) { create(:placements_provider) }

    context "when deleting a user in the same provider as the current user" do
      let(:user) { create(:placements_user, providers: [provider]) }

      it "deletes the user" do
        expect(provider.users).to include(user)
        delete placements_provider_user_path(provider, user)
        expect(flash[:success]).to eq "User removed"
        expect(provider.users).not_to include(user)
      end
    end

    context "when the current user tries to delete themselves" do
      it "shows an error message" do
        delete placements_provider_user_path(provider, current_user)
        expect(flash[:alert]).to eq "You cannot perform this action"
        expect(provider.users).to include(current_user)
      end
    end

    context "when deleting a user in a different provider" do
      let(:another_provider) { build(:placements_provider) }
      let(:user) { create(:placements_user, providers: [another_provider]) }

      it "shows an error message" do
        expect {
          delete placements_provider_user_path(another_provider, user)
        }.to raise_exception(ActiveRecord::RecordNotFound)
        expect(another_provider.users).to include(user)
      end
    end
  end
end
