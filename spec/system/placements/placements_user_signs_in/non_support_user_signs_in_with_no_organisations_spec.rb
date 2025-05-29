require "rails_helper"

RSpec.describe "Non-support user signs in with no organisations", service: :placements, type: :system do
  scenario do
    given_i_am_signed_in
    then_i_see_an_empty_organisations_page
    and_it_is_not_the_support_organisations_page
  end

  private

  def given_i_am_signed_in
    # The user does not have any organisations, so we sign them in without any
    sign_in_placements_user(organisations: [])
  end

  def then_i_see_an_empty_organisations_page
    expect(page).to have_title("Organisations - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations")
    expect(page).to have_paragraph("You are not a member of any placement organisations")
  end

  def and_it_is_not_the_support_organisations_page
    expect(page).not_to have_current_path(placements_support_organisations_path)
  end
end
