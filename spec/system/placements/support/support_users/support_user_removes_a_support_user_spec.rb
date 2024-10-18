require "rails_helper"

RSpec.describe "Placements / Support Users / Support users removes a support user",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let!(:support_user) { create(:placements_support_user, :colin) }
  let!(:support_user_to_be_removed) { create(:placements_support_user) }

  scenario "Remove a support user" do
    given_i_am_signed_in_as_a_support_user
    and_i_visit_the_support_users_page
    and_i_click_on_a_support_user(support_user_to_be_removed)
    and_i_click_on_remove
    then_i_see_the_support_user_removal_confirmation(support_user_to_be_removed)
    when_i_click_on_remove
    then_i_see_the_support_user_has_been_removed(support_user_to_be_removed)
    then_an_email_is_sent(support_user_to_be_removed.email)
  end

  scenario "A support user can not remove themselves as a support user" do
    given_i_sign_in_as(support_user)
    and_i_visit_the_support_users_page
    and_i_click_on_a_support_user(support_user)
    then_i_can_not_see_a_remove_link
  end

  private

  def when_i_sign_in_as_a_support_user(support_user)
    user_exists_in_dfe_sign_in(user: support_user)
    visit placements_root_path
    click_on "Start now"
    click_on "Sign in using DfE Sign In"
  end

  def and_i_visit_the_support_users_page
    within(".govuk-header__navigation-list") do
      click_on "Support users"
    end
  end

  def and_i_click_on_a_support_user(support_user)
    click_on support_user.full_name
  end

  def when_i_click_on_remove
    click_on "Remove support user"
  end
  alias_method :and_i_click_on_remove, :when_i_click_on_remove

  def then_i_see_the_support_user_removal_confirmation(support_user)
    expect(page).to have_content support_user.full_name
    expect(page).to have_content "Are you sure you want to remove this support user?"
  end

  def then_i_see_the_support_user_has_been_removed(support_user)
    expect(page).not_to have_content support_user.full_name
    expect(page).to have_content "Support user removed"
  end

  def then_an_email_is_sent(email)
    email = ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(email) && delivery.subject == "You have been removed from Manage school placements"
    end

    expect(email).not_to be_nil
  end

  def then_i_can_not_see_a_remove_link
    expect(page).not_to have_content("Remove user")
  end
end
