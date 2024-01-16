require "rails_helper"

RSpec.describe "Placements / Support / Users / Support User Invites A New User", type: :system do
  let(:school) { create(:school, :placements, name: "School 1") }
  let(:provider) { create(:placements_provider, name: "Provider 1") }
  let(:new_user) do
    create(:placements_user,
           first_name: "New",
           last_name: "User",
           email: "test@example.com")
  end

  before do
    given_i_am_signed_in_as_a_support_user
    mailer_double = instance_double(ActionMailer::MessageDelivery, deliver_later: nil)
    allow(NotifyMailer).to receive(:send_organisation_invite_email).and_return(mailer_double)
  end

  describe "School" do
    scenario "Support User invites a new user to a school" do
      when_i_visit_the_users_page_for(organisation: school)
      and_i_click("Invite user")
      and_i_enter_the_details_for_a_new_user
      and_i_click("Continue")
      then_i_see_the_new_users_details
      and_i_click("Add user")
      then_i_see_the_new_user_has_been_added
    end
  end

  describe "Provider" do
    scenario "Support User invites a new user to a school" do
      when_i_visit_the_users_page_for(organisation: provider)
      and_i_click("Invite user")
      and_i_enter_the_details_for_a_new_user
      and_i_click("Continue")
      then_i_see_the_new_users_details
      and_i_click("Add user")
      then_i_see_the_new_user_has_been_added
    end
  end

  describe "Invalid form submissions" do
    scenario "Support User invites an existing user" do
      given_a_user_has_been_assigned_to_the(organisation: school)
      when_i_visit_the_users_page_for(organisation: school)
      and_i_click("Invite user")
      and_i_enter_the_details_for_a_new_user
      and_i_click("Continue")
      then_i_see_an_error("This email address is already in use. Try another email address")
    end

    scenario "Support User doesn't enter any user details" do
      when_i_visit_the_users_page_for(organisation: school)
      and_i_click("Invite user")
      and_i_click("Continue")
      then_i_see_an_error("Enter a first name")
      then_i_see_an_error("Enter a last name", 1)
      then_i_see_an_error("Enter an email address", 2)
    end
  end

  private

  def and_there_is_an_existing_persona_for(persona_name)
    create(:persona, persona_name.downcase.to_sym, service: :placements)
  end

  def and_i_visit_the_personas_page
    visit personas_path
  end

  def and_i_click_sign_in_as(persona_name)
    click_on "Sign In as #{persona_name}"
  end

  def given_i_am_signed_in_as_a_support_user
    given_i_am_on_the_placements_site
    and_there_is_an_existing_persona_for("Colin")
    and_i_visit_the_personas_page
    and_i_click_sign_in_as("Colin")
  end

  def when_i_visit_the_users_page_for(organisation:)
    visit placements_support_organisation_users_path(organisation)
  end

  def when_i_click(button_text)
    click_on button_text
  end

  alias_method :and_i_click, :when_i_click

  def and_i_enter_the_details_for_a_new_user
    fill_in "placements-user-first-name-field", with: "New"
    fill_in "placements-user-last-name-field", with: "User"
    fill_in "placements-user-email-field", with: "test@example.com"
  end

  def then_i_see_the_new_users_details
    expect(page).to have_content("New")
    expect(page).to have_content("User")
    expect(page).to have_content("test@example.com")
  end

  alias_method :and_i_see_the_new_users_details, :then_i_see_the_new_users_details

  def then_i_see_the_new_user_has_been_added
    expect(page.find(".govuk-notification-banner__heading")).to have_content("User added")
    and_i_see_the_new_users_details
  end

  def given_a_user_has_been_assigned_to_the(organisation:)
    create(:membership, user: new_user, organisation:)
  end

  def then_i_see_an_error(error_message, error_index = 0)
    # Error summary
    expect(page.find(".govuk-error-summary")).to have_content(
      "There is a problem",
    )
    expect(page.find(".govuk-error-summary")).to have_content(error_message)
    # Error above input
    input_error_messages = page.all(".govuk-error-message")
    expect(input_error_messages[error_index]).to have_content(error_message)
  end
end
