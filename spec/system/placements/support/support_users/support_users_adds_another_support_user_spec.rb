require "rails_helper"

RSpec.describe "Placements support user adds another support user",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_support_user_data_exists
    and_i_am_signed_in

    when_i_am_on_the_support_users_index_page
    then_i_see_a_list_of_existing_support_users

    when_i_click_on_add_support_user
    then_i_see_the_personal_details_form

    when_i_click_back
    then_i_see_the_support_users_index_page

    when_i_click_on_add_support_user
    and_i_click_cancel
    then_i_see_the_support_users_index_page

    when_i_click_on_add_support_user
    and_i_provide_details_of_an_existing_support_user
    and_i_click_on_continue
    then_i_see_a_validation_error_for_email_address_already_in_use

    when_i_provide_details_of_a_user_without_an_education_govuk_email_address
    and_i_click_on_continue
    then_i_see_a_validation_error_for_invalid_email_address

    when_i_provide_valid_details
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_change
    then_i_see_the_personal_details_page_with_details_prefilled

    when_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_add_support_user
    then_i_see_a_success_banner
    and_the_new_user_is_listed_on_the_index_page
    and_an_email_is_sent_to_the_support_user
  end

  private

  def given_support_user_data_exists
    create(:placements_support_user, first_name: "Homer", last_name: "Simpson", email: "homer.simpson@education.gov.uk")
  end

  def and_i_am_signed_in
    given_i_am_signed_in_as_a_placements_support_user
  end

  def when_i_am_on_the_support_users_index_page
    within(".govuk-header__navigation-list") do
      click_on "Support users"
    end
  end

  def then_i_see_a_list_of_existing_support_users
    expect(page).to have_title("Support users - Manage school placements - GOV.UK")
    expect(page).to have_h1("Support users")
    expect(page).to have_link("Add support user", href: "/support/support_users/new")
    expect(page).to have_table_row({
      "Name" => "Homer Simpson",
      "Email address" => "homer.simpson@education.gov.uk",
    })
  end
  alias_method :then_i_see_the_support_users_index_page, :then_i_see_a_list_of_existing_support_users

  def when_i_click_on_add_support_user
    click_on "Add support user"
  end

  def then_i_see_the_personal_details_form
    expect(page).to have_title("Personal details - Add support user - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add support user", class: "govuk-caption-l")
    expect(page).to have_h1("Personal details")
    expect(page).to have_element(:div, text: "Email must be a valid Department for Education address, like name@education.gov.uk.", class: "govuk-hint")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/support/support_users")
  end

  def when_i_click_back
    click_on "Back"
  end

  def and_i_click_cancel
    click_on "Cancel"
  end

  def and_i_provide_details_of_an_existing_support_user
    fill_in "First name", with: "Homer"
    fill_in "Last name", with: "Simpson"
    fill_in "Email address", with: "homer.simpson@education.gov.uk"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end
  alias_method :when_i_click_on_continue, :and_i_click_on_continue

  def then_i_see_a_validation_error_for_email_address_already_in_use
    expect(page).to have_validation_error("Email address already in use")
  end

  def when_i_provide_details_of_a_user_without_an_education_govuk_email_address
    fill_in "First name", with: ""
    fill_in "Last name", with: ""
    fill_in "Email address", with: ""

    fill_in "First name", with: "Bart"
    fill_in "Last name", with: "Simpson"
    fill_in "Email address", with: "bart.simpson@comicbooks.org"
  end

  def then_i_see_a_validation_error_for_invalid_email_address
    expect(page).to have_validation_error("Enter a Department for Education email address in the correct format, like name@education.gov.uk")
  end

  def when_i_provide_valid_details
    fill_in "First name", with: ""
    fill_in "Last name", with: ""
    fill_in "Email address", with: ""

    fill_in "First name", with: "Marge"
    fill_in "Last name", with: "Simpson"
    fill_in "Email address", with: "marge.simpson@education.gov.uk"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers - Add support user - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Add support user", class: "govuk-caption-l")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_summary_list_row("First name", "Marge")
    expect(page).to have_summary_list_row("Last name", "Simpson")
    expect(page).to have_summary_list_row("Email address", "marge.simpson@education.gov.uk")
    expect(page).to have_element(:div, text: "The support user will be sent an email to tell them you’ve added them to Manage school placements.", class: "govuk-warning-text")
    expect(page).to have_button("Add support user")
  end

  def when_i_click_on_change
    click_on "Change", match: :first
  end

  def then_i_see_the_personal_details_page_with_details_prefilled
    within("form") do
      expect(page).to have_field("First name", with: "Marge")
      expect(page).to have_field("Last name", with: "Simpson")
      expect(page).to have_field("Email address", with: "marge.simpson@education.gov.uk")
    end
  end

  def then_i_see_a_success_banner
    expect(page).to have_success_banner("Support user added")
  end

  def and_the_new_user_is_listed_on_the_index_page
    expect(page).to have_table_row({
      "Name" => "Homer Simpson",
      "Email address" => "homer.simpson@education.gov.uk",
    })
    expect(page).to have_table_row({
      "Name" => "Marge Simpson",
      "Email address" => "marge.simpson@education.gov.uk",
    })
  end

  def and_an_email_is_sent_to_the_support_user
    email = ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?("marge.simpson@education.gov.uk") && delivery.subject == "Your invite to the Manage school placements service"
    end

    expect(email).not_to be_nil
  end
end
