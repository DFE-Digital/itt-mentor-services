require "rails_helper"

RSpec.describe PlacementPolicy do
  subject(:placement_policy) { described_class }

  let(:current_user) { create(:placements_user, schools: [school]) }
  let(:placement) { Placement.new(school:) }

  permissions :new?, :edit_provider?, :edit_mentors?, :edit_year_group?, :update?, :add_placement_journey? do
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
