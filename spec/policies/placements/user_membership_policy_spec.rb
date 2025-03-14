require "rails_helper"

RSpec.describe Placements::UserMembershipPolicy do
  subject(:user_membership_policy) { described_class }

  let(:user_membership) { create(:user_membership, user:, organisation:) }

  permissions :destroy?, :remove? do
    context "when the current user tries to delete themselves" do
      let(:current_user) { create(:placements_user) }
      let(:user) { current_user }
      let(:organisation) { create(:school, :placements) }

      it "denies access" do
        expect(user_membership_policy).not_to permit(current_user, user_membership)
      end
    end

    context "when current user is a support user" do
      let(:current_user) { create(:placements_support_user) }
      let(:user) { create(:placements_user) }
      let(:organisation) { create(:school, :placements) }

      it "permits access" do
        expect(user_membership_policy).to permit(current_user, user_membership)
      end
    end

    context "when the current user is not a support user" do
      context "when current user is not associated with the membership's organisation" do
        let(:current_user) { create(:placements_user) }
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:school, :placements) }

        it "denies access" do
          expect(user_membership_policy).not_to permit(current_user, user_membership)
        end
      end

      context "when current user is associated with the membership's school" do
        let(:current_user) { create(:placements_user) }
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:school, :placements) }
        let(:current_user_membership) { create(:user_membership, user: current_user, organisation:) }

        before { current_user_membership }

        it "permit access" do
          expect(user_membership_policy).to permit(current_user, user_membership)
        end
      end

      context "when current user is associated with the membership's provider" do
        let(:current_user) { create(:placements_user) }
        let(:user) { create(:placements_user) }
        let(:organisation) { create(:provider, :placements) }
        let(:current_user_membership) { create(:user_membership, user: current_user, organisation:) }

        before { current_user_membership }

        it "permit access" do
          expect(user_membership_policy).to permit(current_user, user_membership)
        end
      end
    end
  end

  describe "scope" do
    let(:scope) { UserMembership.all }

    before do
      create_list(:user_membership, 3)
    end

    context "when the user is a school user" do
      let(:school) { build(:placements_school) }
      let(:user) { create(:placements_user, user_memberships: [user_membership_1]) }
      let(:user_membership_1) { build(:user_membership, organisation: school) }
      let(:user_membership_2) { create(:user_membership) }

      before do
        user_membership_2
      end

      it "returns the school's user memberships" do
        expect(user_membership_policy::Scope.new(user, scope).resolve).to eq([user_membership_1])
      end
    end
  end
end
