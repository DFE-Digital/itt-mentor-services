require "rails_helper"

RSpec.describe "Placements", service: :placements, type: :request do
  let(:provider) { build(:placements_provider) }
  let(:current_user) { create(:placements_user, providers: [provider]) }

  before do
    sign_in_as current_user
  end

  describe "GET /placements" do
    context "when an organisation is present" do
      before do
        get placements_provider_placements_path(provider)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders the placements index page" do
        expect(response).to render_template("placements/index")
      end
    end
  end
end
