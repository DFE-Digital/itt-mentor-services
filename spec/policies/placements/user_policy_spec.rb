require "rails_helper"

RSpec.describe Placements::UserPolicy do
  subject(:user_policy) { described_class }

  permissions :destroy? do
    context "when current user and user are the the same user" do
      let(:current_user) { create(:placements_user) }
      let(:user) { current_user }

      it "denies access" do
        expect(user_policy).not_to permit(current_user, user)
      end
    end

    context "when current user and user are different users" do
      let(:current_user) { create(:placements_user) }
      let(:user) { create(:placements_user) }

      it "grants access" do
        expect(user_policy).to permit(current_user, user)
      end
    end
  end
end
