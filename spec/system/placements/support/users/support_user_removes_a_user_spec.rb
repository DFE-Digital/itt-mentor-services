require "rails_helper"

RSpec.describe "Placements support user removes a user from an organisation", type: :system, service: :placements do
  include ActiveJob::TestHelper

  let(:feature_flags) { Flipflop::FeatureSet.current.test! }

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  describe "schools" do
    let(:school) { create(:placements_school) }
    let(:user) { create(:placements_user) }

    before do
      create(:user_membership, user:, organisation: school)
    end

    context "when 'placements_user_onboarding_emails' feature flag is enabled" do
      before { feature_flags.switch!(:placements_user_onboarding_emails, true) }

      after { feature_flags.switch!(:placements_user_onboarding_emails, false) }

      scenario "user is removed from a school" do
        given_i_am_signed_in_as_a_support_user
        and_i_visit_the_user_page(school)
        when_i_click_on("Remove user")
        then_i_am_asked_to_confirm(school)
        when_i_click_on("Cancel")
        then_i_return_to_user_page(school)
        when_i_click_on("Remove user")
        then_i_am_asked_to_confirm(school)
        when_i_click_on("Remove user")
        then_the_user_is_removed_from_the_organisation(school)
        and_email_is_sent(user.email, school)
      end
    end

    context "when 'placements_user_onboarding_emails' feature flag is disabled" do
      scenario "user is removed from a school" do
        given_i_am_signed_in_as_a_support_user
        and_i_visit_the_user_page(school)
        when_i_click_on("Remove user")
        then_i_am_asked_to_confirm(school)
        when_i_click_on("Cancel")
        then_i_return_to_user_page(school)
        when_i_click_on("Remove user")
        then_i_am_asked_to_confirm(school)
        when_i_click_on("Remove user")
        then_the_user_is_removed_from_the_organisation(school)
        and_email_is_not_sent(user.email, school)
      end
    end
  end

  describe "providers" do
    let(:provider) { create(:placements_provider) }
    let(:user) { create(:placements_user) }

    before do
      create(:user_membership, user:, organisation: provider)
    end

    context "when 'placements_user_onboarding_emails' feature flag is enabled" do
      before { feature_flags.switch!(:placements_user_onboarding_emails, true) }

      after { feature_flags.switch!(:placements_user_onboarding_emails, false) }

      scenario "user is removed from a provider" do
        given_i_am_signed_in_as_a_support_user
        and_i_visit_the_user_page(provider)
        when_i_click_on("Remove user")
        then_i_am_asked_to_confirm(provider)
        when_i_click_on("Cancel")
        then_i_return_to_user_page(provider)
        when_i_click_on("Remove user")
        then_i_am_asked_to_confirm(provider)
        when_i_click_on("Remove user")
        then_the_user_is_removed_from_the_organisation(provider)
        and_email_is_sent(user.email, provider)
      end
    end

    context "when 'placements_user_onboarding_emails' feature flag is disabled" do
      scenario "user is removed from a provider" do
        given_i_am_signed_in_as_a_support_user
        and_i_visit_the_user_page(provider)
        when_i_click_on("Remove user")
        then_i_am_asked_to_confirm(provider)
        when_i_click_on("Cancel")
        then_i_return_to_user_page(provider)
        when_i_click_on("Remove user")
        then_i_am_asked_to_confirm(provider)
        when_i_click_on("Remove user")
        then_the_user_is_removed_from_the_organisation(provider)
        and_email_is_not_sent(user.email, provider)
      end
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

    scenario "user is removed from one organisation but when other memberships exist" do
      given_i_am_signed_in_as_a_support_user
      and_i_visit_the_user_page(school)
      when_i_remove_user_from_school
      then_user_is_still_member_of_provider
    end
  end

  private

  def when_i_remove_user_from_school
    click_on "Remove user"
    click_on "Remove user"
    expect(page).to have_content "User removed"
    expect(user.user_memberships.find_by(organisation: school)).to eq nil
  end

  def then_user_is_still_member_of_provider
    visit placements_support_provider_users_path(provider)

    expect(page).to have_content user.full_name
  end

  def given_i_am_signed_in_as_a_support_user
    user = create(:placements_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def and_i_visit_the_user_page(organisation)
    click_on organisation.name
    within(".app-secondary-navigation__list") do
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
      "Are you sure you want to remove this user? - #{user.full_name} - #{organisation.name} - Manage school placements",
    )
    expect(page).to have_content "#{user.full_name} - #{organisation.name}"
    expect(page).to have_content "Are you sure you want to remove this user?"
    expect(page).to have_content "The user will be sent an email to tell them you removed them from #{organisation.name}"
  end

  def organisations_is_selected_in_primary_nav
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisations", current: "page"
      expect(page).to have_link "Users", current: "false"
    end
  end

  def users_is_selected_in_secondary_nav(organisation)
    within(".app-secondary-navigation__list") do
      expect(page).to have_link "Details", current: "false"
      expect(page).to have_link "Users", current: "page"
      if organisation.is_a?(Provider)
        expect(page).to have_link "Providers", current: "false"
        expect(page).to have_link "Partner schools", current: "false"
      else
        expect(page).to have_link "Mentors", current: "false"
        expect(page).to have_link "Partner providers", current: "false"
      end
      expect(page).to have_link "Placements", current: "false"
    end
  end

  def then_i_return_to_user_page(organisation)
    organisations_is_selected_in_primary_nav
    case organisation
    when School
      expect(page).to have_current_path placements_support_school_user_path(organisation, user), ignore_query: true
    when Provider
      expect(page).to have_current_path placements_support_provider_user_path(organisation, user), ignore_query: true
    end
  end

  def then_the_user_is_removed_from_the_organisation(organisation)
    organisations_is_selected_in_primary_nav
    users_is_selected_in_secondary_nav(organisation)
    expect(user.user_memberships.find_by(organisation:)).to eq nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "User removed"
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
