require "rails_helper"

RSpec.describe "Home Page", type: :system, service: :claims do
  scenario "User visits the claims homepage with dfe sign in" do
    given_i_am_on_the_start_page
    i_can_see_the_claims_service_name_in_the_header
    i_can_see_the_dfe_sign_in_button
  end

  scenario "User visits the claims homepage with person sign in", persona_sign_in: true do
    given_i_am_on_the_start_page
    i_can_see_the_claims_service_name_in_the_header
    i_can_see_the_persona_sign_in_button
  end

  private

  def given_i_am_on_the_start_page
    visit "/"
  end

  def i_can_see_the_claims_service_name_in_the_header
    within(".govuk-header") do
      expect(page).to have_content("Claim funding for mentors")
    end
  end

  def i_can_see_the_dfe_sign_in_button
    expect(page).to have_content("Sign in using DfE Sign In")
  end

  def i_can_see_the_persona_sign_in_button
    expect(page).to have_content("Sign in using a Persona")
  end
end
