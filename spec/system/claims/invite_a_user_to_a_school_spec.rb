require "rails_helper"

RSpec.describe "Invite a user to a school", type: :system do
  before do
    setup_school
    mailer_double = instance_double(ActionMailer::MessageDelivery, deliver_later: nil)
    allow(NotifyMailer).to receive(:send_school_invite_email).and_return(mailer_double)
  end

  scenario "I sign in as a support user and invite a user to a school" do
    sign_in_as_support_user
    visit_claims_support_school_users_page
    click_on_invite_user_button
    fill_in_user_details
    check_user_details
    click_on_add_user
    verify_user_added
  end

  scenario "I sign in as a support user and invalid bad user details" do
    sign_in_as_support_user
    visit_claims_support_school_users_page
    click_on_invite_user_button
    fill_in_invalid_user_details
  end

  private

  def setup_school
    @school = create(:school, :claims, urn: "123456")
  end

  def sign_in_as_support_user
    create(:persona, :colin, service: "claims")
    visit personas_path
    click_on "Sign In as Colin"
  end

  def visit_claims_support_school_users_page
    visit claims_support_school_users_path(@school)
  end

  def click_on_invite_user_button
    click_on "Invite User"
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

  def verify_user_added
    visit_claims_support_school_users_page
    expect(page).to have_content("Barry Garlow")
    expect(page).to have_content("barry.garlow@eduction.gov.uk")
  end
end
