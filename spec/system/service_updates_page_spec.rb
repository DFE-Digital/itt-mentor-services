require "rails_helper"

RSpec.describe "Service updates page", type: :system do
  context "User is on the Claims site", service: :claims do
    scenario "User visits the Service updates page" do
      and_i_am_on_the_service_updates_page
      i_can_see_the_claims_service_title
    end
  end

  context "User is on the Placements site", service: :placements do
    scenario "User visits the Service updates page" do
      and_i_am_on_the_service_updates_page
      i_can_see_the_placements_service_title
    end
  end

  private

  def and_i_am_on_the_service_updates_page
    visit "/service_updates"
  end

  def i_can_see_the_claims_service_title
    within(".govuk-heading-xl") do
      expect(page).to have_content("Claims news and updates")
    end
  end

  def i_can_see_the_placements_service_title
    within(".govuk-heading-xl") do
      expect(page).to have_content("Placements news and updates")
    end
  end
end
