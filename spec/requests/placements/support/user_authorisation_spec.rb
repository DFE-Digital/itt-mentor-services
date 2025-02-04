require "rails_helper"

RSpec.describe "Support console / user authorization", service: :placements, type: :request do
  let(:support_user) { create(:placements_support_user) }
  let(:non_support_user) { create(:placements_user) }

  let(:school) { create(:placements_school) }
  let(:provider) { create(:placements_provider) }

  let(:support_console_paths) do
    [
      placements_support_organisations_path,
      placements_support_support_users_path,
    ]
  end

  context "when the current user is a support user" do
    before { sign_in_as support_user }

    it "loads the support console" do
      support_console_paths.each do |path|
        get path
        expect(response).to have_http_status(:ok), "Could not load: #{path}"
      end
    end
  end

  context "when the current user is not a support user" do
    before { sign_in_as non_support_user }

    it "redirects to the homepage with an error message" do
      support_console_paths.each do |path|
        get path
        expect(response).not_to have_http_status(:ok), "Route loaded when it shouldn't have: #{path}"
        expect(response.location).to eq(placements_root_url)
        expect(flash[:heading]).to eq("You cannot perform this action")
        expect(flash[:success]).to be false
      end
    end
  end

  context "when the user is not signed in" do
    it "redirects to the sign-in page" do
      support_console_paths.each do |path|
        get path
        expect(response).not_to have_http_status(:ok), "Route loaded when it shouldn't have: #{path}"
        expect(response.location).to eq(sign_in_url)
      end
    end
  end
end
