require "rails_helper"

RSpec.describe UserMembershipPolicy do
  subject(:user_membership_policy) { described_class }

  describe "scope" do
    let(:scope) { UserMembership.all }

    before do
      create_list(:user_membership, 3)
    end

    context "when the user is a school user" do
      let(:user) { create(:placements_user, schools: [school]) }
      let(:school) { build(:placements_school) }

      before do
        user.current_organisation = school
        create(:user_membership, organisation: school)
      end

      it "returns the school's user memberships" do
        expect(user_membership_policy::Scope.new(user, scope).resolve).to eq(user.user_memberships)
      end
    end
  end
end
