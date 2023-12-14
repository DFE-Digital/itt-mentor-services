require "rails_helper"

RSpec.feature "Service updates page" do
  after { Capybara.app_host = nil }

  scenario "User visits the claims Service updates" do
    given_i_am_on_the_claims_site
    and_i_am_on_the_service_updates_page
    i_can_see_the_claims_service_title
  end

  scenario "User visits the placements Service updates" do
    given_i_am_on_the_placements_site
    and_i_am_on_the_service_updates_page
    i_can_see_the_placements_service_title
  end

  private

  def given_i_am_on_the_claims_site
    Capybara.app_host = "http://#{ENV["CLAIMS_HOST"]}"
  end

  def given_i_am_on_the_placements_site
    Capybara.app_host = "http://#{ENV["PLACEMENTS_HOST"]}"
  end

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
