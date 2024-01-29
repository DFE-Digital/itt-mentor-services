require "rails_helper"

RSpec.describe "Placements / Support / Users / Support User Invites A New User", type: :system, service: :placements do
  let!(:school) { create(:placements_school) }
  let!(:provider) { create(:placements_provider, name: "Provider 1") }
  let(:new_user) do
    create(:placements_user,
           first_name: "New",
           last_name: "User",
           email: "test@example.com")
  end

  before do
    given_i_am_signed_in_as_a_support_user
    mailer_double = double(:mailer_double)
    allow(mailer_double).to receive(:deliver_later).and_return true
    allow(NotifyMailer).to receive(:send_organisation_invite_email).and_return(mailer_double)
  end

  describe "School" do
    scenario "Support User invites a new user to a school" do
      when_i_visit_the_users_page_for(organisation: school)
      then_i_see_the_navigation_bars_with_organisations_and_users_selected
      and_i_click("Add user")
      then_i_see_support_navigation_with_organisation_selected
      and_i_enter_the_details_for_a_new_user
      and_i_click("Continue")
      then_i_see_support_navigation_with_organisation_selected
      then_i_see_the_new_users_details
      and_i_click("Add user")
      then_i_see_support_navigation_with_organisation_selected
      then_i_see_the_new_user_has_been_added
    end

    scenario "Support user edits new user details before submitting" do
      when_i_visit_the_users_page_for(organisation: school)
      and_i_click("Add user")
      and_i_enter_the_details_for_a_new_user
      and_i_click("Continue")
      then_i_see_the_new_users_details
      and_i_click("Back")
      then_i_see_a_populated_form
      then_i_change_the_first_name
      and_i_click("Continue")
      then_i_see_edited_details
      when_i_click("Add user")
      then_i_see_edited_new_user_details
    end
  end

  describe "Provider" do
    scenario "Support User invites a new user to a school" do
      when_i_visit_the_users_page_for(organisation: provider)
      then_i_see_the_navigation_bars_with_organisations_and_users_selected
      and_i_click("Add user")
      then_i_see_support_navigation_with_organisation_selected
      and_i_enter_the_details_for_a_new_user
      and_i_click("Continue")
      then_i_see_support_navigation_with_organisation_selected
      then_i_see_the_new_users_details
      and_i_click("Add user")
      then_i_see_support_navigation_with_organisation_selected
      then_i_see_the_new_user_has_been_added
    end
  end

  describe "User can be member of multiple organisations" do
    scenario "Support user invites the same user to multiple organisations" do
      when_i_visit_the_users_page_for(organisation: provider)
      and_i_click("Add user")
      and_i_enter_the_details_for_a_new_user
      and_i_click("Continue")
      then_i_see_the_new_users_details
      and_i_click("Add user")
      then_i_see_the_new_user_has_been_added

      when_i_return_to_organisations_page
      when_i_visit_the_users_page_for(organisation: school)
      and_i_click("Add user")
      and_i_enter_the_details_for_a_new_user
      and_i_click("Continue")
      then_i_see_the_new_users_details
      and_i_click("Add user")
      then_i_see_the_new_user_has_been_added

      and_the_user_has_multiple_memberships
    end
  end

  describe "Invalid form submissions" do
    scenario "Support User invites an existing user" do
      given_a_user_has_been_assigned_to_the(organisation: school)
      when_i_visit_the_users_page_for(organisation: school)
      and_i_click("Add user")
      and_i_enter_the_details_for_a_new_user
      and_i_click("Continue")
      then_i_see_an_error("This email address is already in use. Try another email address")
    end

    scenario "Support User doesn't enter any user details" do
      when_i_visit_the_users_page_for(organisation: school)
      and_i_click("Add user")
      and_i_click("Continue")
      then_i_see_an_error("Enter a first name")
      then_i_see_an_error("Enter a last name", 1)
      then_i_see_an_error("Enter an email address", 2)
    end
  end

  private

  def and_there_is_an_existing_persona_for(persona_name)
    create(:placements_support_user, persona_name.downcase.to_sym)
  end

  def and_i_visit_root_path
    visit placements_root_path
  end

  def and_i_click_on_sign_in
    click_on "Sign in using a Persona"
  end

  def and_i_click_sign_in_as(persona_name)
    click_on "Sign In as #{persona_name}"
  end

  def given_i_am_signed_in_as_a_support_user
    and_there_is_an_existing_persona_for("Colin")
    and_i_visit_root_path
    and_i_click_on_sign_in
    and_i_click_sign_in_as("Colin")
  end

  def when_i_visit_the_users_page_for(organisation:)
    click_on organisation.name
    within(".app-secondary-navigation__list") do
      click_on "Users"
    end
  end

  def when_i_return_to_organisations_page
    visit placements_support_organisations_path
  end

  def when_i_click(button_text)
    click_on button_text
  end

  alias_method :and_i_click, :when_i_click

  def and_i_enter_the_details_for_a_new_user
    fill_in "user-invite-form-first-name-field", with: "New"
    fill_in "user-invite-form-last-name-field", with: "User"
    fill_in "user-invite-form-email-field", with: "test@example.com"
  end

  def then_i_see_the_navigation_bars_with_organisations_and_users_selected
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisations", current: "page"
      expect(page).to have_link "Users", current: "false"
    end

    within(".app-secondary-navigation") do
      expect(page).to have_link "Details", current: "false"
      expect(page).to have_link "Users", current: "page"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Providers", current: "false"
    end
  end

  def then_i_see_a_populated_form
    expect(page).to have_field("First name", with: "New")
    expect(page).to have_field("Last name", with: "User")
    expect(page).to have_field("Email", with: "test@example.com")
  end

  def then_i_change_the_first_name
    fill_in "First name", with: "Firsty"
  end

  def then_i_see_edited_details
    expect(page).to have_content("Firsty")
    expect(page).to have_content("User")
    expect(page).to have_content("test@example.com")
  end

  def then_i_see_edited_new_user_details
    expect(page.find(".govuk-notification-banner__content")).to have_content("User added")
    expect(page).to have_content("Firsty")
    expect(page).to have_content("User")
    expect(page).to have_content("test@example.com")
  end

  def then_i_see_the_new_users_details
    expect(page).to have_content("New")
    expect(page).to have_content("User")
    expect(page).to have_content("test@example.com")
  end

  alias_method :and_i_see_the_new_users_details, :then_i_see_the_new_users_details

  def then_i_see_the_new_user_has_been_added
    expect(page.find(".govuk-notification-banner__content")).to have_content("User added")
    then_i_see_support_navigation_with_organisation_selected
    and_i_see_the_new_users_details
  end

  def and_the_user_has_multiple_memberships
    user = Placements::User.find_by(email: "test@example.com")
    expect(user.schools).to include(school)
    expect(user.providers).to include(provider)
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

  def then_i_see_support_navigation_with_organisation_selected
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisations", current: "page"
      expect(page).to have_link "Users", current: "false"
    end
  end
end
