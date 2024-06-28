require "rails_helper"

RSpec.describe "GoodJob admin dashboard", service: :placements, type: :system do
  scenario "Access the dashboard as a support user" do
    given_i_am_a_support_user
    when_i_go_to_the_dashboard_path
    then_i_can_see_the_dashboard
  end

  scenario "Cannot access the dashboard as a regular user" do
    given_i_am_a_regular_user
    when_i_go_to_the_dashboard_path
    then_i_cannot_see_the_dashboard
  end

  scenario "Cannot access the dashboard as an unauthenticated user" do
    when_i_go_to_the_dashboard_path
    then_i_am_asked_to_sign_in
  end

  private

  def given_i_am_a_support_user
    sign_in_as create(:placements_support_user)
  end

  def given_i_am_a_regular_user
    sign_in_as create(:placements_user)
  end

  def when_i_go_to_the_dashboard_path
    visit "/good_job"
  end

  def then_i_can_see_the_dashboard
    expect(page).to have_content "you're doing a Good Job"
  end

  def then_i_cannot_see_the_dashboard
    expect(page).to have_content "You cannot perform this action"
  end

  def then_i_am_asked_to_sign_in
    expect(page).to have_content "Sign in to Manage school placements"
  end
end
