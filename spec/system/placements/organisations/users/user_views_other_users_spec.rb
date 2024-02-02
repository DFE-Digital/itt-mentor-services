require "rails_helper"

RSpec.describe "Placements user views other users in their organisation", type: :system, service: :placements do
  let(:school) { create(:placements_school, name: "Placements School 1") }
  let(:provider) { create(:placements_provider, name: "Placements Provider 1") }
  let(:anne) { create(:placements_user, :anne) }
  let(:mary) { create(:placements_user, :mary) }

  describe "schools" do
    scenario "user can view other school users" do
      user_exists_in_dfe_sign_in(user: mary)
      given_users_have_been_assigned_to_the(organisation: school)
      when_i_visit_the_users_page
      then_i_see_the_organisation_users
      when_i_click_on_a_users_name(mary.full_name)
      then_i_see_user_details(user: mary)
    end
  end

  describe "providers" do
    scenario "users can view other provider users" do
      user_exists_in_dfe_sign_in(user: anne)
      given_users_have_been_assigned_to_the(organisation: provider)
      when_i_visit_the_users_page
      then_i_see_the_organisation_users
      when_i_click_on_a_users_name(anne.full_name)
      then_i_see_user_details(user: anne)
    end
  end

  private

  def given_users_have_been_assigned_to_the(organisation:)
    [mary, anne].each do |user|
      create(:membership, user:, organisation:)
    end
  end

  def when_i_visit_the_users_page
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
    within(".app-primary-navigation__nav") do
      click_on "Users"
    end
  end

  def then_i_see_the_organisation_users
    users_is_selected_in_navigation
    expect(page).to have_content anne.full_name
    expect(page).to have_content anne.email

    expect(page).to have_content mary.full_name
    expect(page).to have_content mary.email
  end

  def when_i_click_on_a_users_name(user_name)
    click_on user_name
  end

  def then_i_see_user_details(user:)
    users_is_selected_in_navigation
    expect(page).to have_content "First name"
    expect(page).to have_content user.first_name

    expect(page).to have_content "Last name"
    expect(page).to have_content user.last_name

    expect(page).to have_content "Email address"
    expect(page).to have_content user.email
  end

  def users_is_selected_in_navigation
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Mentors", current: "false"
      expect(page).to have_link "Users", current: "page"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end
end
