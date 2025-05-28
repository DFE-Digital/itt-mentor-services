require "rails_helper"

RSpec.describe "Support user encounters DSI failure", service: :placements, type: :system do
  scenario do
    given_i_visit_the_service
    and_dsi_is_not_available
    and_i_click_on_start_now
    then_i_see_the_sign_in_page

    when_i_click_on_sign_in_using_dfe_sign_in
    then_i_see_an_error_page
  end

  private

  def given_i_visit_the_service
    visit placements_root_path
  end

  def and_dsi_is_not_available
    OmniAuth.config.mock_auth[:dfe] = :invalid_credentials
  end

  def and_i_click_on_start_now
    click_on "Start now"
  end

  def then_i_see_the_sign_in_page
    expect(page).to have_title("Manage school placements - GOV.UK")
    expect(page).to have_h1("Sign in to Manage school placements")
  end

  def when_i_click_on_sign_in_using_dfe_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def then_i_see_an_error_page
    expect(page).to have_title("Sorry, there’s a problem with the service - Manage school placements - GOV.UK")
    expect(page).to have_h1("Sorry, there’s a problem with the service")
    expect(page).to have_element(:p, class: "govuk-body", text: "Try again later.")
    expect(page).to have_element(:p, class: "govuk-body", text: "If you reached this page after submitting information then it has not been saved. You’ll need to enter it again when the service is available.")
    expect(page).to have_element(:p, class: "govuk-body", text: "If you have any questions, please email us at Manage.SchoolPlacements@education.gov.uk")
  end
end
