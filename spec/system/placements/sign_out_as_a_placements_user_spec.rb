require "rails_helper"

RSpec.describe "Sign out as a Placements User", type: :system, service: :placements do
  let(:colin) { create(:placements_support_user, :colin) }

  scenario "I sign out" do
    given_there_is_an_existing_placements_user_with_a_school_for(colin)
    when_i_visit_the_sign_in_path
    when_i_click_sign_in
    i_should_see_a_sign_out_button
    when_i_click_sign_out
    i_expect_to_be_on_sign_in_page
  end

  private

  def given_there_is_an_existing_placements_user_with_a_school_for(user)
    user_exists_in_dfe_sign_in(user:)
    create(
      :user_membership,
      user:,
      organisation: create(:school, :placements),
    )
  end

  def when_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def when_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def i_should_see_a_sign_out_button
    expect(page).to have_content("Sign out")
  end

  def when_i_click_sign_out
    click_on "Sign out"
  end

  def i_expect_to_be_on_sign_in_page
    expect(page).to have_content("Sign in to Manage school placements")
    expect(page).to have_content("Sign in using DfE Sign In")
  end
end
