require "rails_helper"

RSpec.describe "Sign in Page", service: :claims, type: :system do
  scenario "User visits the claims sign in page with dfe sign in" do
    given_i_am_on_the_start_page
    i_can_see_the_dfe_logo_in_the_header
    i_can_see_the_dfe_sign_in_button
  end

  scenario "User visits the claims sign in page with person sign in", :persona_sign_in do
    given_i_am_on_the_start_page
    i_can_see_the_dfe_logo_in_the_header
    i_can_see_the_persona_sign_in_button
  end

  private

  def given_i_am_on_the_start_page
    visit sign_in_path
  end

  def i_can_see_the_dfe_logo_in_the_header
    within ".govuk-header__logo" do
      expect(page).to have_css('a.govuk-header__link.govuk-header__link--homepage[href="/"]')

      expect(page).to have_css(
        'img.govuk-header__logotype[alt="Department for Education"][src$="department-for-education_white.png"]',
        visible: :all,
      )
    end
  end

  def i_can_see_the_dfe_sign_in_button
    expect(page).to have_content("Sign in using DfE Sign In")
  end

  def i_can_see_the_persona_sign_in_button
    expect(page).to have_content("Sign in using a Persona")
  end
end
