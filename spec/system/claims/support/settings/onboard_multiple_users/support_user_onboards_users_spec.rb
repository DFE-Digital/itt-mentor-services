require "rails_helper"

RSpec.describe "Support user onboards users", service: :claims, type: :system do
  scenario do
    given_schools_exist
    and_i_am_signed_in
    when_i_navigate_to_the_settings_index_page
    and_i_navigate_to_onboard_multiple_users
    then_i_see_the_upload_page

    when_i_upload_a_valid_file
    when_i_click_on_upload
    then_i_see_the_confirm_users_you_want_to_upload_page

    when_i_click_on_confirm_upload
    then_i_see_a_success_message
  end

  private

  def given_schools_exist
    @london_school = create(:claims_school, name: "London School", urn: "111111")
    @guildford_school = create(:claims_school, name: "Guildford School", urn: "222222")
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

  def when_i_upload_a_valid_file
    attach_file "Upload CSV file", "spec/fixtures/claims/user/upload_users.csv"
  end

  def when_i_click_on_upload
    click_on "Upload"
  end

  def then_i_see_the_confirm_users_you_want_to_upload_page
    expect(page).to have_title("Are you sure you want to upload the users? - Onboard users")
    expect(page).to have_element(:span, text: "Onboard users", class: "govuk-caption-l")
    expect(page).to have_h1("Confirm you want to upload users", class: "govuk-heading-l")
    expect(page).to have_h2(:p, text: "Preview of upload_users.csv", class: "govuk-body")
    expect(page).to have_table_row(
      "1" => "2",
      "school_name" => "London School",
      "school_urn" => "111111",
      "first_name" => "Joe",
      "last_name" => "Bloggs",
      "email" => "joe_bloggs@example.com",
    )
    expect(page).to have_table_row(
      "1" => "3",
      "school_name" => "Guildford School",
      "school_urn" => "222222",
      "first_name" => "Sue",
      "last_name" => "Doe",
      "email" => "sue_doe@example.com",
    )
    expect(page).to have_button("Confirm upload")
  end

  def when_i_click_on_confirm_upload
    click_on "Confirm upload"
  end

  def then_i_see_a_success_message
    expect(page).to have_success_banner(
      "Users CSV uploaded",
      "It may take a moment for the users to load. Refresh the page to see newly uploaded information.",
    )
  end
end
