require "rails_helper"

RSpec.describe "Placements", service: :placements, type: :request do
  describe "PUT /update" do
    let!(:school) { create(:placements_school, name: "School 1", phase: "Primary") }

    before do
      user = create(:placements_user, schools: [school])
      sign_in_as user
    end

    context "when editing mentors" do
      it "returns an error message when the mentor_ids are invalid" do
        placement = create(:placement, school:)

        put edit_placement_placements_school_placement_path(school, placement, step: :mentors), params: {
          placement: { mentor_ids: [] },
        }

        expect(response.body).to include("Select a mentor or not yet known")
      end
    end

    context "when editing a provider" do
      it "returns an error message when the provider_id is not present" do
        placement = create(:placement, school:)

        put edit_placement_placements_school_placement_path(school, placement, step: :provider), params: {
          placement: { provider_id: "" },
        }

        expect(response.body).to include("Select a provider")
      end
    end

    context "when editing a year group" do
      it "returns an error message when the year_group is invalid" do
        placement = create(:placement, school:)

        put edit_placement_placements_school_placement_path(school, placement, step: :year_group), params: {
          placement: { year_group: nil },
        }

        expect(response.body).to include("Select a year group")
      end
    end
  end
end
