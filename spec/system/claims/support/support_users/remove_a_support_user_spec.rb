require "rails_helper"

RSpec.describe "Remove a support user", type: :system do
  let!(:support_user) { create(:claims_support_user, :colin) }
  let!(:support_user_to_be_removed) { create(:claims_support_user) }

  scenario "Remove a support user" do
    when_i_sign_in_as_a_support_user(support_user)
    and_i_visit_the_support_users_page
    and_i_click_on_a_support_user(support_user_to_be_removed)
    and_i_click_on_remove
    i_see_the_support_user_removal_confirmation(support_user_to_be_removed)
    and_i_click_on_remove
    i_see_the_support_user_has_been_removed(support_user_to_be_removed)
  end

  private

  def when_i_sign_in_as_a_support_user(support_user)
    visit claims_root_path
    click_on "Sign in using a Persona"
    click_on "Sign In as #{support_user.first_name}"
  end

  def and_i_visit_the_support_users_page
    within(".app-primary-navigation nav") do
      click_on "Users"
    end
  end

  def and_i_click_on_a_support_user(support_user)
    click_on support_user.full_name
  end

  def and_i_click_on_remove
    click_on "Remove user"
  end

  def i_see_the_support_user_removal_confirmation(support_user)
    expect(page).to have_content support_user.full_name
    expect(page).to have_content "Are you sure you want to remove this user?"
  end

  def i_see_the_support_user_has_been_removed(support_user)
    expect(page).to_not have_content support_user.full_name
    expect(page).to have_content "User removed"
  end
end
