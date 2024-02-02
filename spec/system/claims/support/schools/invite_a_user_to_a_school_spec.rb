require "rails_helper"

RSpec.describe "Invite a user to a school", type: :system do
  before do
    setup_school
    mailer_double = double(:mailer_double)
    allow(mailer_double).to receive(:deliver_later).and_return true
    allow(UserMailer).to receive(:invitation_email).and_return(mailer_double)
  end

  scenario "I sign in as a support user and invite a user to a school" do
    sign_in_as_support_user
    visit_claims_support_school_users_page
    click_on_add_user
    fill_in_user_details
    check_user_details
    click_on_add_user
    verify_user_added
  end

  scenario "I sign in as a support user and enter invalid user details" do
    sign_in_as_support_user
    visit_claims_support_school_users_page
    click_on_add_user
    fill_in_invalid_user_details
    then_see_error_message
  end

  scenario "I try to add a user who already exists" do
    sign_in_as_support_user
    visit_claims_support_school_users_page
    click_on_add_user
    fill_in_user_details
    check_user_details
    click_on_add_user
    and_user_is_added
    click_on_add_user
    fill_in_user_details
    then_see_error_message_for_existing_user
  end

  scenario "I add a user to different schools" do
    another_school_exists
    sign_in_as_support_user
    visit_claims_support_school_users_page
    click_on_add_user
    fill_in_user_details
    check_user_details
    click_on_add_user
    verify_user_added

    visit_another_claims_support_school_users_page
    click_on_add_user
    fill_in_user_details
    check_user_details
    click_on_add_user
    verify_user_added_to_another_school
  end

  scenario "I use back or change to edit my answers" do
    sign_in_as_support_user
    visit_claims_support_school_users_page
    click_on_add_user
    fill_in_user_details
    check_user_details
    click_back
    check_form_is_populated
    edit_first_name
    check_user_details_updated
    click_on_add_user
    verify_edited_user_added
  end

  private

  def setup_school
    @school = create(:school, :claims, urn: "123456")
  end

  def another_school_exists
    @another_school = create(:school, :claims)
  end

  def sign_in_as_support_user
    user = create(:claims_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def visit_claims_support_school_users_page
    visit claims_support_school_users_path(@school)
  end

  def visit_another_claims_support_school_users_page
    visit claims_support_school_users_path(@another_school)
  end

  def fill_in_user_details
    fill_in "First name", with: "Barry"
    fill_in "Last name", with: "Garlow"
    fill_in "Email", with: "barry.garlow@eduction.gov.uk"
    click_on "Continue"
  end

  def fill_in_invalid_user_details
    fill_in "First name", with: "Barry"
    fill_in "Last name", with: "Garlow"
    fill_in "Email", with: "not a valid email"
    click_on "Continue"
  end

  def check_form_is_populated
    expect(page).to have_field("First name", with: "Barry")
    expect(page).to have_field("Last name", with: "Garlow")
    expect(page).to have_field("Email", with: "barry.garlow@eduction.gov.uk")
  end

  def edit_first_name
    fill_in "First name", with: "Larry"
    click_on "Continue"
  end

  def check_user_details_updated
    expect(page).to have_content("Larry")
    expect(page).to have_content("Garlow")
    expect(page).to have_content("barry.garlow@eduction.gov.uk")
  end

  def verify_edited_user_added
    expect(page).to have_content("User added")
    check_user_details_updated
  end

  def then_see_error_message
    expect(page).to have_content("Enter an email address in the correct format, like name@example.com").twice
  end

  def then_see_error_message_for_existing_user
    expect(page).to have_content("Email address already in use").twice
  end

  def show_error_messages
    expect(page).to have_content("Enter an email address in the correct format, like name@example.com")
  end

  def check_user_details
    expect(page).to have_content("Barry")
    expect(page).to have_content("Garlow")
    expect(page).to have_content("barry.garlow@eduction.gov.uk")
  end

  def click_on_add_user
    click_on "Add user"
  end

  def click_back
    click_on "Back"
  end

  def verify_user_added
    visit_claims_support_school_users_page
    check_user_details
  end

  def and_user_is_added
    expect(page).to have_content("User added")
  end

  def verify_user_added_to_another_school
    visit_another_claims_support_school_users_page
    check_user_details
  end
end
