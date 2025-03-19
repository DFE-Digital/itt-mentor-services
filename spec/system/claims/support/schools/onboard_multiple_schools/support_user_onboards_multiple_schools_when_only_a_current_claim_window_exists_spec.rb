require "rails_helper"

RSpec.describe "Support user onboards multiple schools when only a current claim window exists", service: :claims, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_a_current_claim_window_exists
    and_schools_exist
    and_i_am_signed_in
    when_i_navigate_to_onboard_multiple_schools
    then_i_see_the_claim_window_page

    when_i_select_the_current_claim_window
    and_click_on_continue
    then_i_see_the_upload_page

    when_i_upload_a_file_containing_schools_to_be_onboarded
    and_i_click_on_upload
    then_i_see_the_confirmation_page_for_onboarding_schools

    when_i_click_on_back
    then_i_see_the_upload_page

    when_i_upload_a_file_containing_schools_to_be_onboarded
    and_i_click_on_upload
    then_i_see_the_confirmation_page_for_onboarding_schools

    when_i_click_on_confirm_upload
    then_i_see_the_school_onboarding_uploaded_successfully
  end

  private

  def given_a_current_claim_window_exists
    @current_claim_window = create(:claim_window, :current).decorate
  end

  def and_schools_exist
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

  def then_i_see_the_upload_page
    expect(page).to have_title("Upload schools for onboarding - Onboarding")
    expect(page).to have_element(:span, text: "Onboarding", class: "govuk-caption-l")
    expect(page).to have_h1("Upload schools for onboarding", class: "govuk-heading-l")
    expect(page).to have_button("Upload")
  end

  def when_i_upload_a_file_containing_schools_to_be_onboarded
    attach_file "Upload CSV file",
                "spec/fixtures/claims/school/onboarding_schools.csv"
  end

  def and_i_click_on_upload
    click_on "Upload"
  end

  def then_i_see_the_confirmation_page_for_onboarding_schools
    expect(page).to have_title("Confirm you want to upload the schools - Onboarding")
    expect(page).to have_element(:span, text: "Onboarding", class: "govuk-caption-l")
    expect(page).to have_h1("Confirm you want to upload the schools", class: "govuk-heading-l")
    expect(page).to have_h2("onboarding_schools.csv")
    expect(page).to have_table_row(
      "1" => "2",
      "name" => "London School",
      "urn" => "111111",
    )
    expect(page).to have_table_row(
      "1" => "3",
      "name" => "Guildford School",
      "urn" => "222222",
    )
    expect(page).to have_button("Confirm upload")
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def when_i_click_on_confirm_upload
    click_on "Confirm upload"
  end

  def then_i_see_the_school_onboarding_uploaded_successfully
    expect(page).to have_success_banner(
      "School onboarding CSV uploaded",
      "It may take a moment for the onboarded schools to load. Refresh the page to see newly uploaded information.",
    )
  end

  def then_i_see_the_claim_window_page
    expect(page).to have_title("Select a claim window - Onboarding")
    expect(page).to have_element(:span, text: "Onboarding", class: "govuk-caption-l")
    expect(page).to have_element(:h1, text: "Select a claim window", class: "govuk-fieldset__heading")

    expect(page).to have_field(@current_claim_window.name, type: :radio)

    expect(page).not_to have_element(:div, text: "Upcoming", class: "govuk-radios__hint")
  end

  def when_i_select_the_current_claim_window
    choose @current_claim_window.name
  end

  def and_click_on_continue
    click_on "Continue"
  end
end
