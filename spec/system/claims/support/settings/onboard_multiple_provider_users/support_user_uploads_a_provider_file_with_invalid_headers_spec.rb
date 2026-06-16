require "rails_helper"

RSpec.describe "Support user uploads a provider file with invalid headers", service: :claims, type: :system do
  scenario do
    given_providers_exist
    and_i_am_signed_in
    when_i_navigate_to_the_settings_index_page
    and_i_navigate_to_onboard_multiple_provider_users
    then_i_see_the_upload_page

    when_i_upload_a_file_containing_invalid_headers
    and_i_click_on_upload
    then_i_see_the_errors_page
  end

  private

  def given_providers_exist
    create(:claims_provider, name: "London Provider", code: "ABC")
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_settings_index_page
    within(primary_navigation) do
      click_on "Settings"
    end
  end

  def and_i_navigate_to_onboard_multiple_provider_users
    click_on "Invite providers to the service"
  end

  def then_i_see_the_upload_page
    expect(page).to have_title("Upload providers - Onboard providers")
    expect(page).to have_element(:span, text: "Onboard providers", class: "govuk-caption-l")
    expect(page).to have_h1("Upload providers", class: "govuk-heading-l")
    expect(page).to have_button("Upload")
  end

  def when_i_upload_a_file_containing_invalid_headers
    attach_file "Upload CSV file", "spec/fixtures/claims/provider_user/invalid_headers_upload_provider_users.csv"
  end

  def and_i_click_on_upload
    click_on "Upload"
  end

  def then_i_see_the_errors_page
    expect(page).to have_title("Error: Upload providers - Onboard providers - Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_element(:span, text: "Onboard providers", class: "govuk-caption-l")
    expect(page).to have_h1("Upload providers", class: "govuk-heading-l")
    expect(page).to have_element(:h2, text: "There is a problem")
    expect(page).to have_content("Your file needs a column called 'email'.")
  end
end
