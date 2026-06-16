require "rails_helper"

RSpec.describe "Support user does not upload a provider file", service: :claims, type: :system do
  scenario do
    given_providers_exist
    and_i_am_signed_in
    when_i_navigate_to_the_settings_index_page
    and_i_navigate_to_onboard_multiple_provider_users
    then_i_see_the_upload_page

    when_i_click_on_upload
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

  def when_i_click_on_upload
    click_on "Upload"
  end

  def then_i_see_the_errors_page
    expect(page).to have_title("Error: Upload providers - Onboard providers - Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_element(:span, text: "Onboard providers", class: "govuk-caption-l")
    expect(page).to have_h1("Upload providers", class: "govuk-heading-l")
    expect(page).to have_validation_error("Select a CSV file to upload")
  end
end
