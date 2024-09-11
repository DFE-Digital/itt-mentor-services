require "rails_helper"

RSpec.describe "User authorization", service: :placements, type: :request do
  let(:support_user) { create(:placements_support_user) }

  let(:school) { create(:placements_school) }
  let(:provider) { create(:placements_provider) }

  let(:all_app_routes) do
    Rails.application.routes.routes.collect { |route|
      ActionDispatch::Routing::RouteWrapper.new route
    }.reject(&:internal?)
  end

  let(:placements_routes) do
    all_app_routes.select do |route|
      route.controller&.include?("placements") &&
        route.verb == "GET"
    end
  end

  context "when visiting a pages route" do
    let(:placements_pages_routes) do
      placements_routes.select do |route|
        route.controller&.include?("pages")
      end
    end

    context "when the current user is a support user" do
      before { sign_in_as support_user }

      it "grants access" do
        placements_pages_routes.each do |route|
          get route.path.gsub("(.:format)", "")
          expect(response).to have_http_status(:ok), "Could not load: #{route.path}"
        end
      end
    end

    context "when the current user is not a support user" do
      let(:non_support_user) { create(:placements_user) }

      before { sign_in_as non_support_user }

      it "grants access" do
        placements_pages_routes.each do |route|
          get route.path.gsub("(.:format)", "")
          expect(response).to have_http_status(:ok), "Could not load: #{route.path}"
        end
      end
    end
  end

  context "when visiting a schools route" do
    let(:placements_school_routes) do
      placements_routes.select do |route|
        route.controller&.include?("/schools/") &&
          !route.controller&.include?("support") &&
          route.action == "index"
      end
    end

    context "when the current user is a support user" do
      before { sign_in_as support_user }

      it "denies access" do
        placements_school_routes.each do |route|
          get route.path.gsub("(.:format)", "").gsub(":school_id", school.id)
          expect(response).not_to have_http_status(:ok), "Route loaded when it shouldn't have: #{path}"
          expect(response.location).to eq(placements_root_url)
          expect(flash[:alert]).to eq("You cannot perform this action")
        end
      end
    end

    context "when the current user is not support user" do
      context "when associated with the school" do
        let(:school_user) { create(:placements_user, schools: [school]) }

        before { sign_in_as school_user }

        it "grants access" do
          placements_school_routes.each do |route|
            get route.path.gsub("(.:format)", "").gsub(":school_id", school.id)
            expect(response).to have_http_status(:ok), "Could not load: #{path}"
          end
        end
      end
    end

    context "when visiting a provider route" do
      let(:placements_provider_routes) do
        placements_routes.select do |route|
          route.controller&.include?("/providers/") &&
            !route.controller&.include?("support") &&
            route.action == "index"
        end
      end

      context "when the current user is a support user" do
        before { sign_in_as support_user }

        it "denies access" do
          placements_provider_routes.each do |route|
            get route.path.gsub("(.:format)", "")
              .gsub(":provider_id", provider.id)
              .gsub(":partner_school_id", school.id)
            expect(response).not_to have_http_status(:ok), "Route loaded when it shouldn't have: #{path}"
            expect(response.location).to eq(placements_root_url)
            expect(flash[:alert]).to eq("You cannot perform this action")
          end
        end
      end

      context "when the current user is not support user" do
        context "when associated with the school" do
          let(:provider_user) { create(:placements_user, providers: [provider]) }

          before do
            sign_in_as provider_user
            create(:placements_partnership, school:, provider:)
          end

          it "grants access" do
            placements_provider_routes.each do |route|
              get route.path.gsub("(.:format)", "")
                .gsub(":provider_id", provider.id)
                .gsub(":partner_school_id", school.id)
              expect(response).to have_http_status(:ok), "Could not load: #{path}"
            end
          end
        end
      end
    end
  end
end
