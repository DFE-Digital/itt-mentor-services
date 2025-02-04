require "rails_helper"

RSpec.describe "Placements support user deletes a user from an organisation", service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  describe "schools" do
    let(:school) { create(:placements_school) }
    let(:user) { create(:placements_user) }

    before do
      create(:user_membership, user:, organisation: school)
    end

    scenario "user is deleted from a school" do
      given_i_am_signed_in_as_a_placements_support_user
      and_i_visit_the_user_page(school)
      when_i_click_on("Delete user")
      then_i_am_asked_to_confirm(school)
      when_i_click_on("Cancel")
      then_i_return_to_user_page(school)
      when_i_click_on("Delete user")
      then_i_am_asked_to_confirm(school)
      when_i_click_on("Delete user")
      then_the_user_is_deleted_from_the_organisation(school)
      and_email_is_sent(user.email, school)
    end
  end

  describe "providers" do
    let(:provider) { create(:placements_provider) }
    let(:user) { create(:placements_user) }

    before do
      create(:user_membership, user:, organisation: provider)
    end

    scenario "user is deleted from a provider" do
      given_i_am_signed_in_as_a_placements_support_user
      and_i_visit_the_user_page(provider)
      when_i_click_on("Delete user")
      then_i_am_asked_to_confirm(provider)
      when_i_click_on("Cancel")
      then_i_return_to_user_page(provider)
      when_i_click_on("Delete user")
      then_i_am_asked_to_confirm(provider)
      when_i_click_on("Delete user")
      then_the_user_is_deleted_from_the_organisation(provider)
      and_email_is_sent(user.email, provider)
    end
  end

  context "when user is a member of more than one organisation" do
    let(:school) { create(:placements_school) }
    let(:provider) { create(:placements_provider) }
    let(:user) { create(:placements_user) }

    before do
      create(:user_membership, user:, organisation: school)
      create(:user_membership, user:, organisation: provider)
    end

    scenario "user is deleted from one organisation but when other memberships exist" do
      given_i_am_signed_in_as_a_placements_support_user
      and_i_visit_the_user_page(school)
      when_i_delete_user_from_school
      then_user_is_still_member_of_provider
    end
  end

  private

  def when_i_delete_user_from_school
    click_on "Delete user"
    click_on "Delete user"
    expect(page).to have_content "User deleted"
    expect(user.user_memberships.find_by(organisation: school)).to be_nil
  end

  def then_user_is_still_member_of_provider
    visit placements_provider_users_path(provider)

    expect(page).to have_content user.full_name
  end

  def and_i_visit_the_user_page(organisation)
    click_on organisation.name
    within(".app-primary-navigation__list") do
      click_on "Users"
    end
    click_on user.full_name
  end

  def when_i_click_on(text)
    click_on text
  end

  def then_i_am_asked_to_confirm(organisation)
    organisations_is_selected_in_primary_nav
    expect(page).to have_title(
      "Are you sure you want to delete this user? - #{user.full_name} - Manage school placements",
    )
    expect(page).to have_content user.full_name
    expect(page).to have_content "Are you sure you want to delete this user?"
    expect(page).to have_content "The user will be sent an email to tell them you deleted them from #{organisation.name}"
  end

  def organisations_is_selected_in_primary_nav
    within(".govuk-header__navigation-list") do
      expect(page).to have_link "Organisations"
      expect(page).to have_link "Support users"
    end
  end

  def users_is_selected_in_secondary_nav(organisation)
    within(".app-primary-navigation__list") do
      expect(page).to have_link "Organisation details", current: "false"
      expect(page).to have_link "Users", current: "page"
      if organisation.is_a?(Provider)
        expect(page).to have_link "Schools", current: "false"
      else
        expect(page).to have_link "Mentors", current: "false"
        expect(page).to have_link "Providers", current: "false"
        expect(page).to have_link "Placements", current: "false"
      end
    end
  end

  def then_i_return_to_user_page(organisation)
    organisations_is_selected_in_primary_nav
    case organisation
    when School
      expect(page).to have_current_path placements_school_user_path(organisation, user), ignore_query: true
    when Provider
      expect(page).to have_current_path placements_provider_user_path(organisation, user), ignore_query: true
    end
  end

  def then_the_user_is_deleted_from_the_organisation(organisation)
    organisations_is_selected_in_primary_nav
    users_is_selected_in_secondary_nav(organisation)
    expect(user.user_memberships.find_by(organisation:)).to be_nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "User deleted"
    end

    expect(page).not_to have_content user.full_name
  end

  def email_removal_notification(email, _organisation)
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(email) && delivery.subject == "You have been removed from Manage school placements"
    end
  end

  def and_email_is_sent(email, organisation)
    removal_email = email_removal_notification(email, organisation)

    expect(removal_email).not_to be_nil
  end

  def and_email_is_not_sent(email, organisation)
    removal_email = email_removal_notification(email, organisation)

    expect(removal_email).to be_nil
  end
end
