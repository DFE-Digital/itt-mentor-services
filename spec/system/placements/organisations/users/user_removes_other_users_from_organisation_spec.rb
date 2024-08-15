require "rails_helper"

RSpec.describe "Placements support user removes a user from an organisation", service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  describe "schools" do
    let(:school) { create(:placements_school) }
    let(:anne) { create(:placements_user, :anne) }
    let(:mary) { create(:placements_user, :mary) }

    before do
      [anne, mary].each do |user|
        create(:user_membership, user:, organisation: school)
      end
    end

    scenario "user is removed from a school" do
      given_i_am_signed_in_as_mary
      and_i_visit_the_user_page(anne)
      when_i_click_on("Delete user")
      then_i_am_asked_to_confirm(anne, school)
      when_i_click_on("Cancel")
      then_i_return_to_user_page(anne, school)
      when_i_click_on("Delete user")
      then_i_am_asked_to_confirm(anne, school)
      when_i_click_on("Delete user")
      then_the_the_user_is_removed_from_the_organisation(anne, school)
      and_message_is_sent_to_user(anne, school)
    end

    scenario "I try to remove myself from a school" do
      given_i_am_signed_in_as_mary
      when_i_try_to_visit_the_remove_path_for(mary, school)
      then_i_am_redirected_back
    end
  end

  describe "providers" do
    let(:provider) { create(:placements_provider) }
    let(:anne) { create(:placements_user, :anne) }
    let(:mary) { create(:placements_user, :mary) }

    before "message is sent to user" do
      [anne, mary].each do |user|
        create(:user_membership, user:, organisation: provider)
      end
    end

    scenario "user is removed from a provider" do
      given_i_am_signed_in_as_mary
      and_i_visit_the_user_page(anne)
      when_i_click_on("Delete user")
      then_i_am_asked_to_confirm(anne, provider)
      when_i_click_on("Cancel")
      then_i_return_to_user_page(anne, provider)
      when_i_click_on("Delete user")
      then_i_am_asked_to_confirm(anne, provider)
      when_i_click_on("Delete user")
      then_the_the_user_is_removed_from_the_organisation(anne, provider)
      and_message_is_sent_to_user(anne, provider)
    end

    scenario "I try to remove myself from a school" do
      given_i_am_signed_in_as_mary
      when_i_try_to_visit_the_remove_path_for(mary, provider)
      then_i_am_redirected_back
    end
  end

  private

  def given_i_am_signed_in_as_mary
    user_exists_in_dfe_sign_in(user: mary)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def email_removal_notification(email, _organisation)
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(email) && delivery.subject == "You have been removed from Manage school placements"
    end
  end

  def and_message_is_sent_to_user(user, organisation)
    email = email_removal_notification(user.email, organisation)

    expect(email).not_to be_nil
  end

  def and_message_is_not_sent_to_user(user, organisation)
    email = email_removal_notification(user.email, organisation)

    expect(email).to be_nil
  end

  def when_i_click_on(text)
    click_on text
  end

  def and_i_visit_the_user_page(user)
    click_on "Users"
    click_on user.full_name
  end

  def when_i_try_to_visit_the_remove_path_for(user, organisation)
    case organisation
    when School
      visit remove_placements_school_user_path(organisation, user)
    when Provider
      visit remove_placements_provider_user_path(organisation, user)
    end
  end

  def then_i_am_redirected_back
    expect(page).to have_current_path placements_root_path, ignore_query: true

    expect(page).to have_content "You cannot perform this action"
  end

  def then_i_am_asked_to_confirm(user, organisation)
    case organisation
    when School
      users_is_selected_in_schools_primary_nav
    when Provider
      users_is_selected_in_providers_primary_nav
    end

    expect(page).to have_title(
      "Are you sure you want to delete this user? - #{user.full_name} - Manage school placements",
    )
    expect(page).to have_content user.full_name.to_s
    expect(page).to have_content "Are you sure you want to delete this user?"
    expect(page).to have_content "The user will be sent an email to tell them you deleted them from #{organisation.name}"
  end

  def users_is_selected_in_schools_primary_nav
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Users", current: "page"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def users_is_selected_in_providers_primary_nav
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Users", current: "page"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def then_i_return_to_user_page(user, organisation)
    case organisation
    when School
      users_is_selected_in_schools_primary_nav
      expect(page).to have_current_path placements_school_user_path(organisation, user), ignore_query: true
    when Provider
      users_is_selected_in_providers_primary_nav
      expect(page).to have_current_path placements_provider_user_path(organisation, user), ignore_query: true
    end
  end

  def then_the_the_user_is_removed_from_the_organisation(user, organisation)
    case organisation
    when School
      users_is_selected_in_schools_primary_nav
    when Provider
      users_is_selected_in_providers_primary_nav
    end

    expect(user.user_memberships.find_by(organisation:)).to be_nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "User removed"
    end

    expect(page).not_to have_content user.full_name
  end
end
