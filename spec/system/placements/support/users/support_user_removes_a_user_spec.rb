require "rails_helper"

RSpec.describe "Placements support user removes a user from an organisation", type: :system, service: :placements do
  describe "schools" do
    let(:school) { create(:placements_school) }
    let(:user) { create(:placements_user) }

    before "message is sent to user" do
      create(:membership, user:, organisation: school)

      user_mailer = double(:user_mailer)
      expect(UserMailer).to receive(:removal_email).with(user, school) { user_mailer }
      expect(user_mailer).to receive(:deliver_later)
    end

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
      then_the_the_user_is_removed_from_the_organisation(school)
    end
  end

  describe "providers" do
    let(:provider) { create(:placements_provider) }
    let(:user) { create(:placements_user) }

    before "email is sent to user notifying them of the removal" do
      create(:membership, user:, organisation: provider)

      user_mailer = double(:user_mailer)
      expect(UserMailer).to receive(:removal_email).with(user, provider) { user_mailer }
      expect(user_mailer).to receive(:deliver_later)
    end

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
      then_the_the_user_is_removed_from_the_organisation(provider)
    end
  end

  context "user is a member of more than one organisation" do
    let(:school) { create(:placements_school) }
    let(:provider) { create(:placements_provider) }
    let(:user) { create(:placements_user) }

    before "user is sent an email to notify them of the removal" do
      create(:membership, user:, organisation: school)
      create(:membership, user:, organisation: provider)

      user_mailer = double(:user_mailer)
      expect(UserMailer).to receive(:removal_email).with(user, school) { user_mailer }
      expect(user_mailer).to receive(:deliver_later)
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
    expect(user.memberships.find_by(organisation: school)).to eq nil
  end

  def then_user_is_still_member_of_provider
    visit placements_support_provider_users_path(provider)

    expect(page).to have_content user.full_name
  end

  def given_i_am_signed_in_as_a_support_user
    create(:placements_support_user, :colin)
    visit personas_path
    click_on "Sign In as Colin"
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

  def users_is_selected_in_secondary_nav
    within(".app-secondary-navigation__list") do
      expect(page).to have_link "Details", current: "false"
      expect(page).to have_link "Users", current: "page"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Providers", current: "false"
    end
  end

  def then_i_return_to_user_page(organisation)
    organisations_is_selected_in_primary_nav
    case organisation
    when School
      expect(current_path).to eq placements_support_school_user_path(organisation, user)
    when Provider
      expect(current_path).to eq placements_support_provider_user_path(organisation, user)
    end
  end

  def then_the_the_user_is_removed_from_the_organisation(organisation)
    organisations_is_selected_in_primary_nav
    users_is_selected_in_secondary_nav
    expect(user.memberships.find_by(organisation:)).to eq nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "User removed"
    end

    expect(page).to_not have_content user.full_name
  end
end
