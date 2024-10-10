require "rails_helper"

RSpec.describe "View claims payments tab", service: :claims, type: :system do
  scenario "User views the payments tab" do
    given_i_sign_in
    when_i_visit_the_claims_payments_tab
    then_i_should_see_the_payment_actions
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

  def then_i_should_see_the_payment_actions
    expect(page).to have_css("h1", text: "Claims")
    expect(page).to have_css("h2", text: "Payments")

    expect(page).to have_link("Send claims to ESFA", href: new_claims_support_payment_path)
    expect(page).to have_link("Upload ESFA response", href: new_claims_support_payments_confirmation_path)
  end
end
