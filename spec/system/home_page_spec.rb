require "rails_helper"

RSpec.feature "Home Page" do
  after do
    Capybara.app_host = nil
  end

  scenario "User visits the claims homepage" do
    given_i_am_on_the_claims_site
    and_i_am_on_the_start_page
    i_can_see_the_claims_service_name_in_the_header
    and_i_can_see_the_claims_service_value_in_the_page
  end

  scenario "User visits the placements homepage" do
    given_i_am_on_the_placements_site
    and_i_am_on_the_start_page
    i_can_see_the_placements_service_name_in_the_header
    and_i_can_see_the_placements_service_value_in_the_page
  end

  private

  def given_i_am_on_the_claims_site
    ENV["CLAIMS_HOST"] = "claims.localhost"
    Capybara.app_host = "http://#{ENV["CLAIMS_HOST"]}"
  end

  def given_i_am_on_the_placements_site
    ENV["PLACEMENTS_HOST"] = "placements.localhost"
    Capybara.app_host = "http://#{ENV["PLACEMENTS_HOST"]}"
  end

  def and_i_am_on_the_start_page
    visit "/"
  end

  def i_can_see_the_claims_service_name_in_the_header
    within(".govuk-header") do
      expect(page).to have_content("Claim Funding for General Mentors")
    end
  end

  def i_can_see_the_placements_service_name_in_the_header
    within(".govuk-header") do
      expect(page).to have_content("Manage School Placements")
    end
  end

  def and_i_can_see_the_claims_service_value_in_the_page
    expect(page).to have_css(".govuk-summary-list__value", text: "Claims")
  end

  def and_i_can_see_the_placements_service_value_in_the_page
    expect(page).to have_css(".govuk-summary-list__value", text: "Placements")
  end
end
