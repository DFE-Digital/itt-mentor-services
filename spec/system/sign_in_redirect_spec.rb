require "rails_helper"

RSpec.describe "Sign in redirect", service: :placements, type: :system do
  before do
    user_exists_in_dfe_sign_in(user:)
  end

  context "when I am a user" do
    let(:user) { create(:placements_user) }
    let(:school) { create(:placements_school, users: [user]) }

    scenario "Logging in via the root path redirects to the placements page" do
      when_i_visit_the placements_root_path
      and_i_click_on "Start now"
      and_i_sign_in
      then_i_can_see_the_organisations_page
    end

    scenario "Logging in via the sign in path redirects to the organisations page" do
      when_i_visit_the sign_in_path
      and_i_sign_in
      then_i_can_see_the_organisations_page
    end

    scenario "Logging in via the sign out path redirects to the organisations page" do
      visit sign_out_path
      and_i_sign_in
      then_i_can_see_the_organisations_page
    end

    scenario "Logging in via an authenticated path redirects to the requested path" do
      when_i_visit_the placements_school_users_path(school)
      and_i_sign_in
      then_i_can_see_the_placements_school_users_page
    end

    scenario "After being redirected, the user is not redirected again" do
      when_i_visit_the placements_school_users_path(school)
      and_i_sign_in
      then_i_can_see_the_placements_school_users_page
      when_i_visit_the placements_root_path
      and_i_click_on "Start now"
      then_i_can_see_the_placements_school_placements_page
    end
  end

  context "when I am a support user" do
    let(:user) { create(:placements_support_user) }

    scenario "Logging in via the root path redirects to the organisations page" do
      when_i_visit_the placements_root_path
      and_i_click_on "Start now"
      and_i_sign_in
      then_i_can_see_the_support_organisations_page
    end

    scenario "Logging in via the sign in path redirects to the organisations page" do
      when_i_visit_the sign_in_path
      and_i_sign_in
      then_i_can_see_the_support_organisations_page
    end

    scenario "Logging in via the sign out path redirects to the organisations page" do
      when_i_visit_the sign_out_path
      and_i_sign_in
      then_i_can_see_the_support_organisations_page
    end

    scenario "Logging in via an authenticated path redirects to the requested path" do
      when_i_visit_the placements_support_settings_path
      and_i_sign_in
      then_i_can_see_the_placements_support_settings_page
    end

    scenario "After being redirected, the user is not redirected again" do
      when_i_visit_the placements_support_settings_path
      and_i_sign_in
      then_i_can_see_the_placements_support_settings_page
      when_i_visit_the placements_root_path
      and_i_click_on "Start now"
      then_i_can_see_the_support_organisations_page
    end
  end

  private

  def and_i_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the(path)
    visit path
  end

  def and_i_click_on(text)
    click_on text
  end

  def then_i_can_see_the_support_organisations_page
    expect(page).to have_current_path(placements_support_organisations_path)
  end

  def then_i_can_see_the_organisations_page
    expect(page).to have_current_path(placements_organisations_path)
  end

  def then_i_can_see_the_placements_support_settings_page
    expect(page).to have_current_path(placements_support_settings_path)
  end

  def then_i_can_see_the_placements_school_users_page
    expect(page).to have_current_path(placements_school_users_path(school))
  end

  def then_i_can_see_the_placements_school_placements_page
    expect(page).to have_current_path(placements_school_placements_path(school))
  end
end
