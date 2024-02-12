require "rails_helper"

RSpec.describe "Sign out as a Claims User", type: :system, service: :claims do
  let(:colin) { create(:claims_support_user, :colin) }

  scenario "I sign out" do
    given_there_is_an_existing_claims_user_with_a_school_for(colin)
    when_i_visit_the_sign_in_path
    when_i_click_sign_in
    i_should_see_a_sign_out_button
    when_i_click_sign_out
    i_expect_to_be_on_sign_in_page
  end

  private

  def given_there_is_an_existing_claims_user_with_a_school_for(user)
    user_exists_in_dfe_sign_in(user:)
    create(
      :membership,
      user:,
      organisation: create(:school, :claims),
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
    expect(page).to have_content("Sign in to Claim funding for mentors")
    expect(page).to have_content("Sign in using DfE Sign In")
  end
end
