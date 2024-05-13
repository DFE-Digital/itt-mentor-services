require "rails_helper"

RSpec.describe PlacementPolicy do
  subject(:placement_policy) { described_class }

  let(:current_user) { create(:placements_user, schools: [school]) }
  let(:placement) { Placement.new(school:) }

  permissions :new?, :add_phase?, :add_subject?, :add_mentors?, :check_your_answers? do
    context "when the placement's school has no school contact" do
      let(:school) { create(:placements_school, with_school_contact: false) }

      it "denies access" do
        expect(placement_policy).not_to permit(current_user, placement)
      end
    end

    context "when the placement's school has a school contact" do
      let(:school) { create(:placements_school) }

      it "denies access" do
        expect(placement_policy).to permit(current_user, placement)
      end
    end
  end

  permissions :update?, :edit_provider?, :edit_mentors? do
    context "when the placement's school has no school contact" do
      let(:school) { create(:placements_school, with_school_contact: false) }

      it "denies access" do
        expect(placement_policy).not_to permit(current_user, placement)
      end
    end

    context "when the placement's school has a school contact" do
      let(:school) { create(:placements_school) }

      it "denies access" do
        expect(placement_policy).to permit(current_user, placement)
      end
    end
  end
end
