require "rails_helper"

RSpec.describe "Support user uploads a file with invalid headers", service: :claims, type: :system do
  scenario do
    given_schools_exist
    and_i_am_signed_in
    when_i_navigate_to_onboard_multiple_users
    then_i_see_the_upload_page

    when_i_upload_a_file_containing_containing_invalid_headers
    and_i_click_on_upload
    then_i_see_the_errors_page
  end

  private

  def given_schools_exist
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

  def when_i_navigate_to_onboard_multiple_users
    click_on "Upload users"
  end

  def then_i_see_the_upload_page
    expect(page).to have_title("Upload users - Upload users")
    expect(page).to have_element(:span, text: "Upload users", class: "govuk-caption-l")
    expect(page).to have_h1("Upload users", class: "govuk-heading-l")
    expect(page).to have_button("Upload")
  end

  def when_i_upload_a_file_containing_containing_invalid_headers
    attach_file "Upload CSV file",
                "spec/fixtures/claims/user/invalid_headers_upload_users.csv"
  end

  def and_i_click_on_upload
    click_on "Upload"
  end

  def then_i_see_the_errors_page
    expect(page).to have_title("Error: Upload users - Upload users - Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_element(:span, text: "Upload users", class: "govuk-caption-l")
    expect(page).to have_h1("Upload users", class: "govuk-heading-l")
    expect(page).to have_element(:h2, text: "There is a problem")
    expect(page).to have_element(:div, text: "Your file needs a column called ‘email’.", class: "govuk-error-summary")
  end

  def and_click_on_continue
    click_on "Continue"
  end
end
