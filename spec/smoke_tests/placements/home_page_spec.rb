require "rails_helper"

RSpec.describe "Home Page", type: :system, smoke_test: true, service: :placements do
  scenario "User visits the placements homepage" do
    given_i_am_on_the_start_page
    i_can_see_the_placements_service_name_in_the_header
  end

  private

  def given_i_am_on_the_start_page
    visit "/"
  end

  def i_can_see_the_placements_service_name_in_the_header
    within(".govuk-header") do
      expect(page).to have_content("Manage school placements")
    end
  end
end
