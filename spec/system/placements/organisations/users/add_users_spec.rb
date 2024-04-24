require "rails_helper"

RSpec.describe "Placements users invite other users to organisations", type: :system, service: :placements do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let(:anne) { create(:placements_user, :anne) }
  let(:one_school) { create(:placements_school, name: "One School") }
  let(:one_provider) { create(:placements_provider, name: "One Provider") }
  let(:mary) { create(:placements_user, :mary) }
  let(:another_school) { create(:placements_school, name: "Another School") }
  let(:new_user) { create(:placements_user) }
  let(:feature_flags) { Flipflop::FeatureSet.current.test! }

  describe "Ann invites a member successfully" do
    context "when 'user_onboarding_emails' feature flag is enabled" do
      before { feature_flags.switch!(:user_onboarding_emails, true) }

      after { feature_flags.switch!(:user_onboarding_emails, false) }

      context "with provider" do
        scenario "user invites a member to a provider" do
          given_i_am_logged_in_as_a_user_with_one_organisation(one_provider)
          when_i_click_users
          then_i_see_the_users_page
          when_i_click_add_user
          and_i_enter_valid_user_details
          and_user_is_selected_in_provider_primary_navigation
          then_i_can_check_my_answers(one_provider)
          when_i_click_back
          then_i_see_prepopulated_form
          when_i_change_user_details
          then_i_see_changes_in_check_form
          and_user_is_selected_in_provider_primary_navigation
          when_i_click_add_user
          then_the_user_is_added(one_provider)
          and_an_email_is_sent("firsty_lasty@email.co.uk", one_provider)
          and_user_is_selected_in_provider_primary_navigation
        end
      end

      context "with school" do
        scenario "user invites a member to a school" do
          given_i_am_logged_in_as_a_user_with_one_organisation(one_school)
          when_i_click_users
          then_i_see_the_users_page
          and_user_is_selected_in_school_primary_navigation
          when_i_click_add_user
          and_user_is_selected_in_school_primary_navigation
          and_i_enter_valid_user_details
          then_i_can_check_my_answers(one_school)
          when_i_click_back
          then_i_see_prepopulated_form
          and_user_is_selected_in_school_primary_navigation
          when_i_change_user_details
          then_i_see_changes_in_check_form
          and_user_is_selected_in_school_primary_navigation
          when_i_click_add_user
          then_the_user_is_added(one_school)
          and_an_email_is_sent("firsty_lasty@email.co.uk", one_school)
        end
      end
    end

    context "when 'user_onboarding_emails' feature flag is disabled" do
      context "with provider" do
        scenario "user invites a member to a provider" do
          given_i_am_logged_in_as_a_user_with_one_organisation(one_provider)
          when_i_click_users
          then_i_see_the_users_page
          when_i_click_add_user
          and_i_enter_valid_user_details
          and_user_is_selected_in_provider_primary_navigation
          then_i_can_check_my_answers(one_provider)
          when_i_click_back
          then_i_see_prepopulated_form
          when_i_change_user_details
          then_i_see_changes_in_check_form
          and_user_is_selected_in_provider_primary_navigation
          when_i_click_add_user
          then_the_user_is_added(one_provider)
          and_an_email_is_not_sent("firsty_lasty@email.co.uk", one_provider)
          and_user_is_selected_in_provider_primary_navigation
        end
      end

      context "with school" do
        scenario "user invites a member to a school" do
          given_i_am_logged_in_as_a_user_with_one_organisation(one_school)
          when_i_click_users
          then_i_see_the_users_page
          and_user_is_selected_in_school_primary_navigation
          when_i_click_add_user
          and_user_is_selected_in_school_primary_navigation
          and_i_enter_valid_user_details
          then_i_can_check_my_answers(one_school)
          when_i_click_back
          then_i_see_prepopulated_form
          and_user_is_selected_in_school_primary_navigation
          when_i_change_user_details
          then_i_see_changes_in_check_form
          and_user_is_selected_in_school_primary_navigation
          when_i_click_add_user
          then_the_user_is_added(one_school)
          and_an_email_is_not_sent("firsty_lasty@email.co.uk", one_school)
        end
      end
    end
  end

  describe "Mary invites a members to second organisation" do
    before "user is sent an invitation" do
      create(:user_membership, user: mary, organisation: one_school)
      create(:user_membership, user: mary, organisation: another_school)
      create(:user_membership, user: mary, organisation: one_provider)
    end

    context "when 'user_onboarding_emails' feature flag is enabled" do
      before { feature_flags.switch!(:user_onboarding_emails, true) }

      after { feature_flags.switch!(:user_onboarding_emails, false) }

      scenario "user adds a user to multiple organisations" do
        given_i_am_logged_in_as_a_user_with_multiple_organisations
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

    context "when 'user_onboarding_emails' feature flag is disabled" do
      scenario "user adds a user to multiple organisations" do
        given_i_am_logged_in_as_a_user_with_multiple_organisations
        and_user_is_already_assigned_to_a_school
        when_i_navigate_to_that_schools_users
        then_i_see_the_user_on_that_schools_user_list
        when_i_change_organisation(another_school)
        and_i_try_to_add_the_user
        then_the_user_is_added_successfully(another_school)
        and_an_email_is_not_sent(new_user.email, another_school)
        when_i_change_organisation(one_provider)
        and_i_try_to_add_the_user
        then_the_user_is_added_successfully(one_provider)
        and_an_email_is_not_sent(new_user.email, one_provider)
      end
    end
  end

  scenario "user tries to submit invalid form" do
    given_i_am_logged_in_as_a_user_with_one_organisation(one_school)
    when_i_click_users
    then_i_see_the_users_page
    when_i_click_add_user
    and_try_to_submit_invalid_form_data
    then_i_see_form_errors
  end

  scenario "user tries to add an existing user to the organisation" do
    given_i_am_logged_in_as_a_user_with_one_organisation(one_school)
    and_user_is_already_assigned_to_a_school
    when_i_try_to_add_the_user_to_the_same_school
    then_i_see_the_email_taken_error
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

  def given_i_am_logged_in_as_a_user_with_one_organisation(organisation)
    user_exists_in_dfe_sign_in(user: anne)
    create(:user_membership, user: anne, organisation:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_i_am_logged_in_as_a_user_with_multiple_organisations
    user_exists_in_dfe_sign_in(user: mary)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
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
    click_on "Add user"
  end

  def then_the_user_is_added_successfully(_organisation)
    expect(page.find(".govuk-notification-banner__content")).to have_content("User added")
    expect(page).to have_content new_user.full_name
    expect(page).to have_content new_user.email
  end

  def when_i_click_users
    click_on "Users"
  end

  def then_i_see_the_users_page
    expect(page).to have_content "Anne Wilson"
    expect(page).to have_content "anne_wilson@example.org"
  end

  def when_i_click_add_user
    click_on "Add user"
  end

  def and_i_enter_valid_user_details
    fill_in "First name", with: "First Namey"
    fill_in "Last name", with: "Last Namey"
    fill_in "Email", with: "firsty_lasty@email.co.uk"
    click_on "Continue"
  end

  def then_i_can_check_my_answers(organisation)
    expect(page).to have_content "First Namey"
    expect(page).to have_content "Last Namey"
    expect(page).to have_content "firsty_lasty@email.co.uk"
    expect(page).to have_content "The user will be sent an email to tell them you’ve added them to #{organisation.name}."
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

  def then_the_user_is_added(_organisation)
    expect(page.find(".govuk-notification-banner__content")).to have_content("User added")
    expect(page).to have_content "New First Name Last Namey"
    expect(page).to have_content "firsty_lasty@email.co.uk"
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

  def email_invite_notification(email, organisation)
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(email) && delivery.subject == "You have been invited to #{organisation.name}"
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
end
