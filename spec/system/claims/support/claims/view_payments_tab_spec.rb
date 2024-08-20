require "rails_helper"

RSpec.describe "View claims payments tab", service: :claims, type: :system do
  scenario "User views the payments tab" do
    given_i_sign_in
    when_i_visit_the_claims_payments_tab
    then_i_should_see_the_payments_instructions

    when_i_click_on_the_submit_button
    then_i_am_redirected_to_the_claims_payments_tab
  end

  private

  def given_i_sign_in
    user_exists_in_dfe_sign_in(user: create(:claims_support_user))
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_claims_payments_tab
    click_on "Claims"
    click_on "Payments"
  end

  def then_i_should_see_the_payments_instructions
    expect(page).to have_content("Payments")
    expect(page).to have_content("Download a CSV of all submitted claims.")
    expect(page).to have_content("Send the CSV from step one to ESFA.")
    expect(page).to have_content("Once ESFA have completed payments, they will return the CSV with successfully paid claims marked as \"Paid\".")
    expect(page).to have_content("When ESFA return the CSV, upload it here.")
    expect(page).to have_content("The CSV will the payments to the payments tab.")
  end

  def when_i_click_on_the_submit_button
    click_on "Save and continue"
  end

  def then_i_am_redirected_to_the_claims_payments_tab
    expect(page).to have_current_path(claims_support_claims_payment_path)
  end
end
