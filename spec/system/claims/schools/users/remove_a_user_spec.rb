require "rails_helper"

RSpec.describe "Remove a user", type: :system, service: :claims do
  let!(:school) { create(:claims_school) }
  let!(:user) do
    create(:claims_user) { |user| school.users << user }
  end
  let!(:current_user) do
    create(:claims_user) { |user| school.users << user }
  end

  scenario "I sign in as a user and remove a user from a school" do
    given_i_am_signed_in_as(current_user)
    and_i_navigate_to_user_details_page(user)
    when_i_click_on_remove_user
    then_i_am_taken_to_a_removal_confirmation_page(school, user)
    when_i_click_on_remove_user
    then_the_user_has_been_removed_from_the_school(user)
  end

  scenario "I sign in as a user and I do not see the link to remove myself from a school" do
    given_i_am_signed_in_as(current_user)
    and_i_navigate_to_user_details_page(current_user)
    then_i_do_not_see_the_remove_user_button
  end

  scenario "I sign in as a user and I cannot remove myself from a school" do
    given_i_am_signed_in_as(current_user)
    and_i_navigate_to_user_removal_page(school, current_user)
    then_i_am_forbidden_to_perform_this_action
  end

  private

  def given_i_am_signed_in_as(user)
    sign_in_as user
  end

  def and_i_navigate_to_user_details_page(user)
    within(".app-primary-navigation") do
      click_on "Users"
    end

    click_on user.full_name
  end

  def and_i_navigate_to_user_removal_page(school, user)
    visit remove_claims_school_user_path(school, user)
  end

  def when_i_click_on_remove_user
    click_on "Remove user"
  end

  def then_i_am_taken_to_a_removal_confirmation_page(school, user)
    expect(page).to have_content user.full_name
    expect(page).to have_content "#{user.full_name} will be sent an email to tell them you removed them from #{school.name}."
  end

  def then_the_user_has_been_removed_from_the_school(user)
    expect(page).to have_content "User removed"

    expect(page).not_to have_content user.full_name
    expect(page).not_to have_content user.email
  end

  def then_i_do_not_see_the_remove_user_button
    expect(page).not_to have_content "Remove user"
  end

  def then_i_am_forbidden_to_perform_this_action
    expect(page).to have_content "You cannot perform this action"
  end
end
