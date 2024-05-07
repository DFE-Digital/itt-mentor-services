require "rails_helper"

RSpec.describe "Placements / Support Users / Support user adds a support user",
               type: :system,
               service: :placements do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let!(:support_user) { create(:placements_support_user, :colin) }

  scenario "Add a support user" do
    when_i_sign_in_as_a_support_user(support_user)
    and_i_visit_the_support_users_page
    and_i_click_on_add_a_support_user
    and_i_fill_in_the_support_user_form(email_address: "john.doe@education.gov.uk")
    then_i_am_redirected_to_check_the_support_user_details
    when_i_click_on_add_user
    then_i_see_the_support_user_has_been_added(email_address: "john.doe@education.gov.uk")
    and_an_email_is_sent_to_the_support_user(email_address: "john.doe@education.gov.uk")
  end

  scenario "Attempt to add a support user without an @education.gov.uk email address" do
    when_i_sign_in_as_a_support_user(support_user)
    and_i_visit_the_support_users_page
    and_i_click_on_add_a_support_user
    and_i_fill_in_the_support_user_form(email_address: "john.doe@example.com")
    then_i_see_an_error("Enter a Department for Education email address in the correct format, like name@education.gov.uk")
    and_the_page_title_is("Error: Personal details - Add user - Manage school placements")
  end

  scenario "Attempt to add a support user with an email that already exists in the system" do
    given_there_is_a_support_user_with(email_address: "john.doe@education.gov.uk")
    when_i_sign_in_as_a_support_user(support_user)
    and_i_visit_the_support_users_page
    and_i_click_on_add_a_support_user
    and_i_fill_in_the_support_user_form(email_address: "john.doe@education.gov.uk")
    then_i_see_an_error("Email address already in use")
    and_the_page_title_is("Error: Personal details - Add user - Manage school placements")
  end

  scenario "Make changes while adding a support user" do
    when_i_sign_in_as_a_support_user(support_user)
    and_i_visit_the_support_users_page
    and_i_click_on_add_a_support_user
    and_i_fill_in_the_support_user_form(email_address: "john.doe@education.gov.uk")
    and_i_click_on_a_change_link
    then_i_should_see_the_support_user_form_with(email_address: "john.doe@education.gov.uk")
    when_i_fill_in_the_support_user_form(email_address: "jane.doe@education.gov.uk")
    and_i_click_on_add_user
    then_i_see_the_support_user_has_been_added(email_address: "jane.doe@education.gov.uk")
    and_an_email_is_sent_to_the_support_user(email_address: "jane.doe@education.gov.uk")
  end

  private

  def given_there_is_a_support_user_with(email_address:)
    create(:placements_support_user, email: email_address)
  end

  def when_i_sign_in_as_a_support_user(support_user)
    user_exists_in_dfe_sign_in(user: support_user)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def and_i_visit_the_support_users_page
    within(".app-primary-navigation nav") do
      click_on "Users"
    end
  end

  def and_i_click_on_add_a_support_user
    click_on "Add user"
  end

  def when_i_fill_in_the_support_user_form(email_address:)
    fill_in "First name", with: "John"
    fill_in "Last name", with: "Doe"
    fill_in "Email address", with: email_address

    click_on "Continue"
  end
  alias_method :and_i_fill_in_the_support_user_form, :when_i_fill_in_the_support_user_form

  def then_i_am_redirected_to_check_the_support_user_details
    expect(page).to have_content "Check your answers"

    expect(page).to have_content "John"
    expect(page).to have_content "Doe"
    expect(page).to have_content "john.doe@education.gov.uk"
  end

  def when_i_click_on_add_user
    click_on "Add user"
  end
  alias_method :and_i_click_on_add_user, :when_i_click_on_add_user

  def then_i_see_the_support_user_has_been_added(email_address:)
    expect(page).to have_content "User added"
    expect(page).to have_content email_address
  end

  def and_an_email_is_sent_to_the_support_user(email_address:)
    email = ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(email_address) && delivery.subject =~ /Invitation to join Claim funding for mentor training/
    end

    expect(email).not_to be_nil
  end

  def and_i_click_on_a_change_link
    click_on "Change", match: :first
  end

  def then_i_should_see_the_support_user_form_with(email_address:)
    within("form") do
      expect(page).to have_field("support_user[email]", with: email_address)
    end
  end

  def then_i_see_an_error(message)
    expect(page).to have_content "There is a problem"
    expect(page).to have_content message, count: 2
  end

  def and_the_page_title_is(title)
    expect(page).to have_title title
  end
end
