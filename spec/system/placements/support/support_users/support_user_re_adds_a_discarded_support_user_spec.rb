require "rails_helper"

RSpec.describe "Placements / Support Users / Support user re-adds a discarded support user",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario "Re-add a discarded support user" do
    given_a_discarded_support_user_with(
      email_address: "john.doe@education.gov.uk",
      first_name: "John",
      last_name: "Doe",
    )
    given_i_am_signed_in_as_a_placements_support_user
    and_i_visit_the_support_users_page
    and_i_click_on_add_a_support_user
    and_i_fill_in_the_support_user_form(
      email_address: "john.doe@education.gov.uk",
      first_name: "John",
      last_name: "Doe",
    )
    then_i_am_redirected_to_check_the_support_user_details
    and_the_support_user_details_displayed_are(
      email_address: "john.doe@education.gov.uk",
      first_name: "John",
      last_name: "Doe",
    )
    when_i_click_on_add_user
    i_see_the_support_user_has_been_added(email_address: "john.doe@education.gov.uk")
    and_an_email_is_sent_to_the_support_user(email_address: "john.doe@education.gov.uk")
  end

  scenario "Re-add a discareded support user and change their details" do
    given_a_discarded_support_user_with(
      email_address: "john.doe@education.gov.uk",
      first_name: "John",
      last_name: "Doe",
    )
    given_i_am_signed_in_as_a_placements_support_user
    and_i_visit_the_support_users_page
    and_i_click_on_add_a_support_user
    and_i_fill_in_the_support_user_form(
      email_address: "john.doe@education.gov.uk",
      first_name: "Johnny",
      last_name: "Dorian",
    )
    then_i_am_redirected_to_check_the_support_user_details
    and_the_support_user_details_displayed_are(
      email_address: "john.doe@education.gov.uk",
      first_name: "Johnny",
      last_name: "Dorian",
    )
    when_i_click_on_add_user
    i_see_the_support_user_has_been_added(email_address: "john.doe@education.gov.uk")
    and_an_email_is_sent_to_the_support_user(email_address: "john.doe@education.gov.uk")
  end

  scenario "Re-add a discarded support user with empty details" do
    given_a_discarded_support_user_with(
      email_address: "john.doe@education.gov.uk",
      first_name: "John",
      last_name: "Doe",
    )
    given_i_am_signed_in_as_a_placements_support_user
    and_i_visit_the_support_users_page
    and_i_click_on_add_a_support_user
    and_i_fill_in_the_support_user_form(
      email_address: "john.doe@education.gov.uk",
      first_name: "",
      last_name: "",
    )
    then_i_see_an_error("Enter a first name")
    and_i_see_an_error("Enter a last name")
  end

  private

  def given_a_discarded_support_user_with(email_address:, first_name:, last_name:)
    create(:placements_support_user, :discarded, email: email_address, first_name:, last_name:)
  end

  def and_i_visit_the_support_users_page
    within(".govuk-header__navigation-list") do
      click_on "Support users"
    end
  end

  def and_i_click_on_add_a_support_user
    click_on "Add support user"
  end

  def and_i_fill_in_the_support_user_form(email_address:, first_name:, last_name:)
    fill_in "First name", with: first_name
    fill_in "Last name", with: last_name
    fill_in "Email address", with: email_address

    click_on "Continue"
  end

  def then_i_am_redirected_to_check_the_support_user_details
    expect(page).to have_content "Check your answers"
  end

  def and_the_support_user_details_displayed_are(email_address:, first_name:, last_name:)
    expect(page).to have_content email_address
    expect(page).to have_content first_name
    expect(page).to have_content last_name
  end

  def when_i_click_on_add_user
    click_on "Add support user"
  end

  def i_see_the_support_user_has_been_added(email_address:)
    expect(page).to have_content "Support user added"
    expect(page).to have_content email_address
  end

  def and_an_email_is_sent_to_the_support_user(email_address:)
    email = ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(email_address) &&
        delivery.subject == "Your invite to the Manage school placements service"
    end

    expect(email).not_to be_nil
  end

  def then_i_click_on_a_change_link
    click_on "Change", match: :first
  end

  def then_i_see_an_error(message)
    expect(page).to have_content "There is a problem"
    expect(page).to have_content message, count: 2
  end
  alias_method :and_i_see_an_error, :then_i_see_an_error

  def and_the_page_title_is(title)
    expect(page).to have_title title
  end
end
