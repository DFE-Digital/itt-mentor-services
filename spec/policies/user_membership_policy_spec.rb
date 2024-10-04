require "rails_helper"

RSpec.describe UserMembershipPolicy do
  subject(:user_membership_policy) { described_class }

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
