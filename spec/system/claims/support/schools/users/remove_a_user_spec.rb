require "rails_helper"

RSpec.describe "Remove a user", type: :system, service: :claims do
  let!(:school) { create(:claims_school) }
  let!(:user) do
    create(:claims_user) { |user| school.users << user }
  end

  scenario "I sign in as a support user and invite a user to a school" do
    given_i_am_signed_in_as_support_user
    and_i_navigate_to_a_school_user_details_page(school, user)
    when_i_click_on_remove_user
    then_i_am_taken_to_a_removal_confirmation_page(school, user)
    when_i_click_on_remove_user
    then_the_user_has_been_removed_from_the_school(school, user)
  end

  private

  def given_i_am_signed_in_as_support_user
    sign_in_as create(:claims_support_user)
  end

  def and_i_navigate_to_a_school_user_details_page(school, user)
    click_on school.name

    within(".app-secondary-navigation") do
      click_on "Users"
    end

    click_on user.full_name
  end

  def when_i_click_on_remove_user
    click_on "Remove user"
  end

  def then_i_am_taken_to_a_removal_confirmation_page(school, user)
    expect(page).to have_content "#{user.full_name} - #{school.name}"
    expect(page).to have_content "The user will be sent an email to tell them you removed them from #{school.name}."
  end

  def then_the_user_has_been_removed_from_the_school(_school, user)
    expect(page).to have_content "User removed"

    expect(page).not_to have_content user.full_name
    expect(page).not_to have_content user.email
  end
end
