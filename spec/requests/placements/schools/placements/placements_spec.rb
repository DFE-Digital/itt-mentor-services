require "rails_helper"

RSpec.describe "Placements", type: :request, service: :placements do
  describe "PATCH /update" do
    let!(:school) { create(:placements_school, name: "School 1", phase: "Primary") }

    before do
      user = create(:placements_user, schools: [school])
      user_exists_in_dfe_sign_in(user:)

      get "/auth/dfe/callback"

      follow_redirect!
    end

    context "when editing mentors" do
      it "returns an error message when the mentor_ids are invalid" do
        placement = create(:placement, school:)

        patch placements_school_placement_path(school, placement), params: {
          placement: { mentor_ids: [] },
          edit_path: "edit_mentors",
        }

        expect(response.body).to include("Select a mentor or not yet known")
      end
    end

    context "when editing a provider" do
      it "returns an error message when the provider_id is not present" do
        placement = create(:placement, school:)

        patch placements_school_placement_path(school, placement), params: {
          placement: { provider_id: "" },
          edit_path: "edit_provider",
        }

        expect(response.body).to include("Select a provider")
      end
    end
  end
end
