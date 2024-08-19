require "rails_helper"

RSpec.describe Placements::Routes::PlacementsHelper do
  describe ".placements_school_placement_details_path" do
    let(:school) { create(:placements_school) }
    let!(:placement) { create(:placement, school:) }

    context "when the path is for a support view" do
      it "returns a path to view the placement as a support user" do
        expect(
          placements_school_placement_details_path(school:, placement:, support: true),
        ).to eq(
          placements_support_school_placement_path(school, placement),
        )
      end
    end

    context "when the path is not for a support view" do
      it "returns a path to view the placement as a school user" do
        expect(
          placements_school_placement_details_path(school:, placement:, support: false),
        ).to eq(
          placements_school_placement_path(school, placement),
        )
      end
    end
  end
end
