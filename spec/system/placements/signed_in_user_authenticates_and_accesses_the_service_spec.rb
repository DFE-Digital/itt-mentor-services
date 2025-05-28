require "rails_helper"

RSpec.describe "Signed in user authenticates and accesses the service", service: :placements, type: :system do
  scenario do
    given_a_school_exists
    and_i_am_signed_in
    then_i_see_the_placements_page
  end

  private

  def given_a_school_exists
    @school = create(:placements_school, name: "Hogwarts")
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
  end

  def then_i_see_the_placements_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Hogwarts", class: "govuk-heading-s")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(page).to have_link("Add placement")
    expect(page).to have_link("Add multiple placements")
  end
end
