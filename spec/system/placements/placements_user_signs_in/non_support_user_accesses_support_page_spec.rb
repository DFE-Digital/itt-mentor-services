require "rails_helper"

RSpec.describe "Non-support user accesses support page", service: :placements, type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_an_empty_organisations_page

    when_i_visit_a_support_page
    then_i_do_not_have_access_to_view_it
  end

  private

  def given_i_am_signed_in
    # The user does not have any organisations, so we sign them in without any
    sign_in_placements_user(organisations: [])
  end

  def then_i_see_an_empty_organisations_page
    expect(page).to have_title("Organisations - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations")
    expect(page).to have_element(:p, text: "You are not a member of any placement organisations", class: "govuk-body")
  end

  def when_i_visit_a_support_page
    visit placements_support_organisations_path
  end

  def then_i_do_not_have_access_to_view_it
    expect(page).to have_title("Manage school placements - GOV.UK")
    expect(page).to have_important_banner("You cannot perform this action")
    expect(page).to have_h1("Manage school placements")
  end
end
