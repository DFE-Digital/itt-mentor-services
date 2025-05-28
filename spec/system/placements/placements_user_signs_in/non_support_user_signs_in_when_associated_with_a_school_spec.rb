require "rails_helper"

RSpec.describe "Non-support user signs in when associated with a school", service: :placements, type: :system do
  scenario do
    given_a_school_exists
    and_i_am_signed_in
    then_i_see_the_placements_page
    and_it_is_not_the_support_organisations_page
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
  end

  def and_it_is_not_the_support_organisations_page
    expect(page).not_to have_current_path(placements_support_organisations_path)
  end
end
