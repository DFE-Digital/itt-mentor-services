require "rails_helper"

RSpec.describe "Hosting interest next steps", service: :placements, type: :request do
  let(:school) { create(:placements_school, with_hosting_interest: false) }
  let(:current_user) { create(:placements_user, schools: [school]) }

  before do
    create(:hosting_interest, :for_next_year, school:, appetite: "not_open")
    sign_in_as current_user
  end

  describe "GET /schools/:school_id/hosting_interests/whats_next" do
    before do
      get whats_next_placements_school_hosting_interests_path(school)
    end

    it "renders the not-open confirmation" do
      expect(response).to have_http_status(:success)
      expect(response).to render_template("placements/schools/hosting_interests/add_hosting_interest/whats_next")
      expect(response.body).to include(
        "We will ask in the next academic year whether you are able to offer placements for trainee teachers.",
      )
    end
  end
end
