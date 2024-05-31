require "rails_helper"

describe Placements::MentorMembershipPolicy do
  subject(:placements_mentor_membership_policy) { described_class }

  let!(:current_user) { create(:placements_user) }
  let!(:school) { create(:placements_school) }
  let!(:mentor) { create(:placements_mentor) }
  let!(:mentor_membership) do
    create(:placements_mentor_membership, school:, mentor:)
  end

  permissions :destroy? do
    context "when the mentor has no placements" do
      it "grants access" do
        expect(
          placements_mentor_membership_policy,
        ).to permit(current_user, mentor_membership)
      end
    end

    context "when the mentor has placements" do
      before do
        create(:placement,
               school:,
               mentors: [mentor])
      end

      it "denies access" do
        expect(
          placements_mentor_membership_policy,
        ).not_to permit(current_user, mentor_membership)
      end
    end
  end
end
