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
        get placements_placements_path
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "renders the placements index page" do
        expect(response).to render_template("placements/index")
      end
    end

    context "when an organisation is not present" do
      let(:dfe_sign_in_user_double) { instance_double(DfESignInUser) }

      before do
        allow(DfESignInUser).to receive(:new).and_return(dfe_sign_in_user_double)
        allow(dfe_sign_in_user_double).to receive(:user).and_return(current_user)
        allow(current_user).to receive(:current_organisation).and_return(nil)
        get placements_placements_path
      end

      it "redirects the user to the organisations page if the current user does not have a current organisation" do
        expect(response).to redirect_to placements_organisations_path
      end
    end
  end
end
