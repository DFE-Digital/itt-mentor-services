require "rails_helper"

RSpec.describe "Support user onboards users for an invalid school urn", service: :claims, type: :system do
  scenario do
    pending "Validation temp removed"
    given_schools_exist
    and_i_am_signed_in
    when_i_navigate_to_the_settings_index_page
    and_i_navigate_to_onboard_multiple_users
    then_i_see_the_upload_page

    when_i_upload_a_valid_file_with_invalid_school_urns
    when_i_click_on_upload
    then_i_see_the_errors_page
  end

  private

  def given_schools_exist
    @london_school = create(:school, name: "London School", urn: "111111")
    @guildford_school = create(:school, name: "Guildford School", urn: "222222")
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_settings_index_page
    within(primary_navigation) do
      click_on "Settings"
    end
  end

  def and_i_navigate_to_onboard_multiple_users
    click_on "Onboard users"
  end

  def then_i_see_the_upload_page
    expect(page).to have_title("Upload users - Onboard users")
    expect(page).to have_element(:span, text: "Onboard users", class: "govuk-caption-l")
    expect(page).to have_h1("Upload users", class: "govuk-heading-l")
    expect(page).to have_button("Upload")
  end

  def when_i_upload_a_valid_file_with_invalid_school_urns
    attach_file "Upload CSV file", "spec/fixtures/claims/user/upload_users.csv"
  end

  def when_i_click_on_upload
    click_on "Upload"
  end

  def then_i_see_the_errors_page
    expect(page).to have_title("Error: Upload users - Onboard users - Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_element(:span, text: "Onboard users", class: "govuk-caption-l")
    expect(page).to have_h1("Upload users", class: "govuk-heading-l")
    expect(page).to have_element(:h2, text: "There is a problem")
    expect(page).to have_element(:div, text: "You need to fix 2 errors related to specific rows", class: "govuk-error-summary")
    expect(page).to have_element(:td, text: "Enter a valid onboarded school urn", class: "govuk-table__cell", count: 2)
    expect(page).to have_element(:p, text: "Only showing rows with errors", class: "govuk-!-text-align-centre")
  end
end
