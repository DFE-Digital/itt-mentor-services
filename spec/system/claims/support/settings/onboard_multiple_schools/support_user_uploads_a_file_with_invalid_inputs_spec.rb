require "rails_helper"

RSpec.describe "Support user uploads a file with invalid inputs", service: :claims, type: :system do
  scenario do
    given_claim_windows_exist
    and_schools_exist
    and_i_am_signed_in
    when_i_navigate_to_the_settings_index_page
    and_i_navigate_to_onboard_multiple_schools
    then_i_see_the_claim_window_page

    when_i_select_the_upcoming_claim_window
    and_click_on_continue
    then_i_see_the_upload_page

    when_i_upload_a_file_containing_containing_invalid_inputs
    and_i_click_on_upload
    then_i_see_the_errors_page
  end

  private

  def given_claim_windows_exist
    @current_claim_window = create(:claim_window, :current).decorate
    @upcoming_claim_window = create(:claim_window, :upcoming).decorate
  end

  def and_schools_exist
    @london_school = create(:school, name: "London School", urn: 111_111)
    @guildford_school = create(:school, name: "Guildford School", urn: 222_222)
    @york_school = create(:school, name: "York School", urn: 333_333)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_settings_index_page
    within(primary_navigation) do
      click_on "Settings"
    end
  end

  def and_i_navigate_to_onboard_multiple_schools
    click_on "Onboard schools"
  end

  def then_i_see_the_upload_page
    expect(page).to have_title("Upload schools for onboarding - Onboarding")
    expect(page).to have_element(:span, text: "Onboarding", class: "govuk-caption-l")
    expect(page).to have_h1("Upload schools for onboarding", class: "govuk-heading-l")
    expect(page).to have_button("Upload")
  end

  def when_i_upload_a_file_containing_containing_invalid_inputs
    attach_file "Upload CSV file",
                "spec/fixtures/claims/school/invalid_onboading_schools.csv"
  end

  def and_i_click_on_upload
    click_on "Upload"
  end

  def then_i_see_the_errors_page
    expect(page).to have_title("Upload schools for onboarding - Onboarding")
    expect(page).to have_element(:span, text: "Onboarding", class: "govuk-caption-l")
    expect(page).to have_h1("Upload schools for onboarding", class: "govuk-heading-l")
    expect(page).to have_element(:h2, text: "There is a problem")
    expect(page).to have_element(:div, text: "You need to fix 2 errors related to specific rows", class: "govuk-error-summary")
    expect(page).to have_element(:td, text: "Enter a valid name", class: "govuk-table__cell", count: 1)
    expect(page).to have_element(:td, text: "Enter a valid urn", class: "govuk-table__cell", count: 1)
    expect(page).to have_element(:p, text: "Only showing rows with errors", class: "govuk-!-text-align-centre")
  end

  def then_i_see_the_claim_window_page
    expect(page).to have_title("Select a claim window - Onboarding")
    expect(page).to have_element(:span, text: "Onboarding", class: "govuk-caption-l")
    expect(page).to have_element(:h1, text: "Select a claim window", class: "govuk-fieldset__heading")

    expect(page).to have_field(@current_claim_window.name, type: :radio)
    expect(page).to have_field(@upcoming_claim_window.name, type: :radio)
  end

  def when_i_select_the_upcoming_claim_window
    choose @upcoming_claim_window.name
  end

  def and_click_on_continue
    click_on "Continue"
  end
end
