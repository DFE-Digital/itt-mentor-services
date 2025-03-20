require "rails_helper"

RSpec.describe "Support user can not onboard schools when there are no claim windows",
               service: :claims,
               type: :system do
  scenario do
    given_schools_exist
    and_i_am_signed_in
    when_i_navigate_to_onboard_multiple_schools
    then_i_see_the_no_claim_window_page
  end

  private

  def given_schools_exist
    @london_school = create(:school, name: "London School", urn: 111_111)
    @guildford_school = create(:school, name: "Guildford School", urn: 222_222)
    @york_school = create(:school, name: "York School", urn: 333_333)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_organisations_index_page
    within(primary_navigation) do
      click_on "Organisations"
    end
  end

  def when_i_navigate_to_onboard_multiple_schools
    visit new_onboard_schools_claims_support_schools_path
  end

  def then_i_see_the_no_claim_window_page
    expect(page).to have_title("Error: No claim windows - Onboarding")
    expect(page).to have_element(:span, text: "Onboarding", class: "govuk-caption-l")
    expect(page).to have_h1("No claim windows", class: "govuk-heading-l")
    expect(page).to have_element(
      :p,
      text: "There are currently no claim windows available to allow schools to be eligible to claim funding for mentor training.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "To onboard a school you will need to create a claim window (opens in new tab).",
      class: "govuk-body",
    )
    expect(page).to have_link("create a claim window (opens in new tab)")
  end
end
