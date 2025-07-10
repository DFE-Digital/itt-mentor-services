require "rails_helper"

RSpec.describe "Support user views manually onboarded schools when none are present", service: :claims, type: :system do
  scenario do
    given_i_am_signed_in
    when_i_navigate_to_the_settings_index_page
    then_i_see_the_manually_onboarded_schools_link

    when_i_click_on_the_manually_onboarded_schools_link
    then_i_do_not_see_any_schools
  end

  private

  def given_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_settings_index_page
    within(primary_navigation) do
      click_on "Settings"
    end
  end

  def then_i_see_the_manually_onboarded_schools_link
    expect(page).to have_link("View manually onboarded schools", href: "/support/manually_onboarded_schools")
  end

  def when_i_click_on_the_manually_onboarded_schools_link
    click_on "View manually onboarded schools"
  end

  def then_i_do_not_see_any_schools
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_link("Settings", href: "/support/settings")
    expect(page).to have_h1("Manually onboarded schools", class: "govuk-heading-l")
    expect(page).to have_paragraph("No manually onboarded schools found.")
  end
end
