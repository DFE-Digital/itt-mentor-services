require "rails_helper"

RSpec.describe "View claims sampling tab", service: :claims, type: :system do
  scenario "User views the sampling tab" do
    given_i_sign_in
    when_i_visit_the_claims_sampling_tab
    then_i_should_see_the_sampling_instructions

    when_i_click_on_the_submit_button
    then_i_am_redirected_to_the_claims_sampling_tab
  end

  private

  def given_i_sign_in
    user_exists_in_dfe_sign_in(user: create(:claims_support_user))
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_claims_sampling_tab
    click_on "Claims"
    click_on "Sampling"
  end

  def then_i_should_see_the_sampling_instructions
    expect(page).to have_content("Sampling")
    expect(page).to have_content("Fetch the download CSV of sample claims.")
    expect(page).to have_content("Upload it.")
    expect(page).to have_content("Do we need any other instructions for the user here?")
  end

  def when_i_click_on_the_submit_button
    click_on "Save and continue"
  end

  def then_i_am_redirected_to_the_claims_sampling_tab
    expect(page).to have_current_path(claims_support_claims_sampling_path)
  end
end
