require "rails_helper"

RSpec.describe "Placements users invite other users to organisations", service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let(:one_school) { create(:placements_school, name: "One School") }
  let(:one_provider) { create(:placements_provider, name: "One Provider") }
  let(:another_school) { create(:placements_school, name: "Another School") }
  let(:new_user) { create(:placements_user) }

  describe "Ann invites a member successfully" do
    context "with provider" do
      scenario "user invites a member to a provider" do
        given_i_am_signed_in_as_a_placements_user(organisations: [one_provider])
        when_i_click_users
        then_i_see_the_users_page_for_provider(one_provider)
        when_i_click_add_user
        and_i_enter_valid_user_details
        and_user_is_selected_in_provider_primary_navigation
        then_i_can_check_my_answers(:provider)
        when_i_click_back
        then_i_see_prepopulated_form
        when_i_change_user_details
        then_i_see_changes_in_check_form
        and_user_is_selected_in_provider_primary_navigation
        when_i_click_confirm
        then_the_user_is_added
        and_an_email_is_sent("firsty_lasty@email.co.uk", one_provider)
        and_user_is_selected_in_provider_primary_navigation
      end
    end

    context "with school" do
      scenario "user invites a member to a school" do
        given_i_am_signed_in_as_a_placements_user(organisations: [one_school])
        when_i_click_users
        then_i_see_the_users_page_for_school(one_school)
        and_user_is_selected_in_school_primary_navigation
        when_i_click_add_user
        and_user_is_selected_in_school_primary_navigation
        and_i_enter_valid_user_details
        then_i_can_check_my_answers(:school)
        when_i_click_back
        then_i_see_prepopulated_form
        and_user_is_selected_in_school_primary_navigation
        when_i_change_user_details
        then_i_see_changes_in_check_form
        and_user_is_selected_in_school_primary_navigation
        when_i_click_confirm
        then_the_user_is_added
        and_an_email_is_sent("firsty_lasty@email.co.uk", one_school)
      end
    end
  end

  describe "Mary invites a members to second organisation" do
    scenario "user adds a user to multiple organisations" do
      given_i_am_signed_in_as_a_placements_user(
        organisations: [one_provider, one_school, another_school],
      )
      and_user_is_already_assigned_to_a_school
      when_i_navigate_to_that_schools_users
      then_i_see_the_user_on_that_schools_user_list
      when_i_change_organisation(another_school)
      and_i_try_to_add_the_user
      then_the_user_is_added_successfully(another_school)
      and_an_email_is_sent(new_user.email, another_school)
      when_i_change_organisation(one_provider)
      and_i_try_to_add_the_user
      then_the_user_is_added_successfully(one_provider)
      and_an_email_is_sent(new_user.email, one_provider)
    end
  end

  scenario "user tries to submit invalid form" do
    given_i_am_signed_in_as_a_placements_user(organisations: [one_school])
    when_i_click_users
    then_i_see_the_users_page_for_school(one_school)
    when_i_click_add_user
    and_try_to_submit_invalid_form_data
    then_i_see_form_errors
  end

  scenario "user tries to add an existing user to the organisation" do
    given_i_am_signed_in_as_a_placements_user(organisations: [one_school])
    and_user_is_already_assigned_to_a_school
    when_i_try_to_add_the_user_to_the_same_school
    then_i_see_the_email_taken_error
  end

  describe "when I use multiple tabs to add users", :js do
    let(:windows) do
      {
        open_new_window => { first_name: "Herschel", last_name: "Fowler", email: "herschel.fowler@example.com" },
        open_new_window => { first_name: "Barbara", last_name: "Heaton", email: "barbara.heaton@example.com" },
      }
    end

    before { given_i_am_signed_in_as_a_placements_user(organisations: [one_school]) }

    it "persists the user details for each tab upon refresh" do
      windows.each do |window, details|
        within_window window do
          visit placements_school_placements_path(one_school)
          when_i_click_users
          then_i_see_the_users_page_for_school(one_school)
          and_user_is_selected_in_school_primary_navigation
          when_i_click_add_user
          and_user_is_selected_in_school_primary_navigation
          and_i_enter_valid_user_details(**details)
          then_i_can_check_my_answers(:school, **details)
        end
      end

      # We need this test to be A -> B -> A -> B, so we can't combine the loops.
      # rubocop:disable Style/CombinableLoops
      windows.each do |window, details|
        within_window window do
          when_i_refresh_the_page
          then_the_user_details_have_not_changed(:school, **details)
          when_i_click_confirm
          then_the_user_is_added(**details)
        end
      end
      # rubocop:enable Style/CombinableLoops

      visit placements_school_placements_path(one_school)
      when_i_click_users
      then_i_see_my_users(windows.values)
    end
  end

  private

  def and_try_to_submit_invalid_form_data
    fill_in "Email", with: "firsty_lasty"
    click_on "Continue"
  end

  def then_i_see_form_errors
    expect(page.find(".govuk-error-summary")).to have_content "There is a problem"
    expect(page).to have_content("Enter a first name").twice
    expect(page).to have_content("Enter a last name").twice
    expect(page).to have_content("Enter an email address in the correct format, like name@example.com").twice
  end

  def then_i_see_the_email_taken_error
    expect(page.find(".govuk-error-summary")).to have_content "There is a problem"
    expect(page).to have_content("Email address already in use")
  end

  def and_user_is_already_assigned_to_a_school
    create(:user_membership, user: new_user, organisation: one_school)
  end

  def when_i_try_to_add_the_user_to_the_same_school
    click_on "Users"
    click_on "Add user"
    fill_in "First name", with: new_user.first_name
    fill_in "Last name", with: new_user.last_name
    fill_in "Email", with: new_user.email
    click_on "Continue"
  end

  def when_i_navigate_to_that_schools_users
    click_on "One School"
    click_on "Users"
  end

  def then_i_see_the_user_on_that_schools_user_list
    expect(page).to have_content(new_user.full_name)
    expect(page).to have_content(new_user.email)
  end

  def when_i_change_organisation(organisation)
    click_on "Change organisation"
    click_on organisation.name
    click_on "Users"
  end

  def and_i_try_to_add_the_user
    click_on "Add user"
    fill_in "First name", with: new_user.first_name
    fill_in "Last name", with: new_user.last_name
    fill_in "Email", with: new_user.email
    click_on "Continue"
    click_on "Confirm and add user"
  end

  def then_the_user_is_added_successfully(_organisation)
    expect(page.find(".govuk-notification-banner__content")).to have_content("User added")
    expect(page).to have_content new_user.full_name
    expect(page).to have_content new_user.email
  end

  def when_i_click_users
    click_on "Users"
  end

  def then_i_see_the_users_page_for_school(school)
    expect(page).to have_current_path placements_school_users_path(school), ignore_query: true
  end

  def then_i_see_the_users_page_for_provider(provider)
    expect(page).to have_current_path placements_provider_users_path(provider), ignore_query: true
  end

  def when_i_click_add_user
    click_on "Add user"
  end

  def when_i_click_confirm
    click_on "Confirm and add user"
  end

  def and_i_enter_valid_user_details(first_name: "First Namey", last_name: "Last Namey", email: "firsty_lasty@email.co.uk")
    fill_in "First name", with: first_name
    fill_in "Last name", with: last_name
    fill_in "Email", with: email
    click_on "Continue"
  end

  def then_i_can_check_my_answers(organisation_type, first_name: "First Namey", last_name: "Last Namey", email: "firsty_lasty@email.co.uk")
    expect(page).to have_content first_name
    expect(page).to have_content last_name
    expect(page).to have_content email
    if organisation_type == :school
      expect(page).to have_content "Once added, they will be able to view, edit and create placements at your school."
    end
    expect(page).to have_content "We will send them an email with information on how to access the Manage school placements service."
  end

  def when_i_click_back
    click_on "Back"
  end

  def then_i_see_prepopulated_form
    expect(page).to have_field("First name", with: "First Namey")
    expect(page).to have_field("Last name", with: "Last Namey")
    expect(page).to have_field("Email", with: "firsty_lasty@email.co.uk")
  end

  def when_i_change_user_details
    fill_in "First name", with: "New First Name"
    click_on "Continue"
  end

  def then_i_see_changes_in_check_form
    expect(page).to have_content "New First Name"
    expect(page).to have_content "Last Namey"
    expect(page).to have_content "firsty_lasty@email.co.uk"
  end

  def then_the_user_is_added(first_name: "New First Name", last_name: "Last Namey", email: "firsty_lasty@email.co.uk")
    expect(page.find(".govuk-notification-banner__content")).to have_content("User added")
    expect(page).to have_content "#{first_name} #{last_name}"
    expect(page).to have_content email
  end

  def and_user_is_selected_in_school_primary_navigation
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Users", current: "page"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def and_user_is_selected_in_provider_primary_navigation
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Users", current: "page"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def email_invite_notification(email, _organisation)
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(email) && delivery.subject == "Invitation to join Manage school placements"
    end
  end

  def and_an_email_is_sent(email, organisation)
    invite_email = email_invite_notification(email, organisation)

    expect(invite_email).not_to be_nil
  end

  def and_an_email_is_not_sent(email, organisation)
    invite_email = email_invite_notification(email, organisation)

    expect(invite_email).to be_nil
  end

  def when_i_refresh_the_page
    visit current_path
  end

  def then_i_see_my_users(users)
    users.each do |user|
      expect(page).to have_content(user[:first_name])
      expect(page).to have_content(user[:last_name])
      expect(page).to have_content(user[:email])
    end
  end

  alias_method :then_the_user_details_have_not_changed, :then_i_can_check_my_answers
end
