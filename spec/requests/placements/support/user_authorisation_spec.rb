require "rails_helper"

RSpec.describe "Support console / user authorization", type: :request, service: :placements do
  let(:support_user) { create(:placements_support_user) }
  let(:non_support_user) { create(:placements_user) }

  let(:school) { create(:placements_school) }
  let(:provider) { create(:placements_provider) }

  let(:support_console_paths) do
    [
      placements_support_organisations_path,
      placements_support_support_users_path,
      placements_support_school_path(school),
      placements_support_school_users_path(school),
      placements_support_school_partner_providers_path(school),
      placements_support_school_mentors_path(school),
      placements_support_school_placements_path(school),
      placements_support_provider_path(provider),
      placements_support_provider_users_path(provider),
      placements_support_provider_partner_schools_path(provider),
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
        expect(flash[:alert]).to eq("You cannot perform this action")
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

  def sign_in_as(user)
    user_exists_in_dfe_sign_in(user:)
    get "/auth/dfe/callback"
    follow_redirect!
  end
end
