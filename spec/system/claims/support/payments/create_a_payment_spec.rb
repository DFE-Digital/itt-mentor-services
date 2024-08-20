require "rails_helper"

RSpec.describe "Create a new payment", service: :claims, type: :system do
  context "when there are no submitted claims" do
    scenario "User cannot create a new payment" do
      given_i_sign_in
      when_i_attempt_to_send_claims_to_esfa
      then_i_should_see_an_error_page
    end
  end

  context "when there are submitted claims", freeze: "26 September 2024 13:11" do
    before do
      create_list(:claim, 3, :submitted)\
    end

    scenario "User creates a new payment" do
      given_i_sign_in
      when_i_attempt_to_send_claims_to_esfa
      then_i_should_see_a_confirmation_page

      when_i_confirm_sending_claims_to_esfa
      then_i_see_a_success_message
    end
  end

  private

  def given_i_sign_in
    user_exists_in_dfe_sign_in(user: create(:claims_support_user, first_name: "Colin", last_name: "Chapman"))
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_attempt_to_send_claims_to_esfa
    click_on "Claims"
    click_on "Payments"
    click_on "Send claims to ESFA"
  end

  def then_i_should_see_an_error_page
    expect(page).to have_css("h1", text: "There are no claims to send for payment")
    expect(page).to have_content("You cannot send any claims to the ESFA because there are no claims pending payment.")
  end

  def then_i_should_see_a_confirmation_page
    expect(page).to have_css("h1", text: "Send claims to ESFA")

    expect(page).to have_content("Selecting ‘Send claims’ will:")
    expect(page).to have_content("create a CSV containing a list of all ‘Submitted’ claims")
    expect(page).to have_content("send an email to the ESFA containing a link to the generated CSV - this link expires after 7 days")
    expect(page).to have_content("update the claim status from ‘Submitted’ to ‘Pending payment’")

    expect(page).to have_content("This action cannot be undone.")
  end

  def when_i_confirm_sending_claims_to_esfa
    click_on "Send claims"
  end

  def then_i_see_a_success_message
    expect(page).to have_css("h3", text: "Claims sent to ESFA")
  end
end
