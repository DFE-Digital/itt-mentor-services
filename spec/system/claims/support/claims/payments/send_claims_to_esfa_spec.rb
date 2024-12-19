require "rails_helper"

RSpec.describe "Send claims to ESFA", service: :claims, type: :system do
  let(:support_user) { create(:claims_support_user) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
  end

  scenario "Support user attempts to send claims to ESFA, but there are no 'submitted' claims" do
    given_i_sign_in
    when_i_visit_claims_payments_index_page
    when_i_click_on_send_claims_to_esfa
    then_i_can_see_an_error_page
  end

  context "when there are submitted claims" do
    before do
      create_list(:claim, 3, :submitted)
    end

    scenario "Support user sends claims to ESFA" do
      given_i_sign_in
      when_i_visit_claims_payments_index_page
      when_i_click_on_send_claims_to_esfa
      then_i_can_see_a_confirmation_page

      when_i_click_on_send_claims
      then_i_see_a_success_flash_message
      and_claims_have_been_sent_to_esfa
    end
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_claims_payments_index_page
    click_on("Claims")
    click_on("Payments")
  end

  def when_i_click_on_send_claims_to_esfa
    click_on("Send claims to ESFA")
  end

  def then_i_can_see_an_error_page
    expect(page).to have_css("p.govuk-caption-l", text: "Payments")
    expect(page).to have_css("h1.govuk-heading-l", text: "There are no claims to send for payment")
    expect(page).to have_css("p.govuk-body", text: "You cannot send any claims to the ESFA because there are no claims pending payment.")
    expect(page).to have_link("Cancel", href: claims_support_claims_payments_path)
  end

  def then_i_can_see_a_confirmation_page
    expect(page).to have_css("p.govuk-caption-l", text: "Payments")
    expect(page).to have_css("h1.govuk-heading-l", text: "Send claims to ESFA")
    expect(page).to have_css("p.govuk-body", text: "There are 3 claims included in this submission.")
    expect(page).to have_css("p.govuk-body", text: "Selecting ‘Send claims’ will:")
    expect(page).to have_css("li", text: "create a CSV containing a list of all ‘Submitted’ claims")
    expect(page).to have_css("li", text: "send an email to the ESFA containing a link to the generated CSV - this link expires after 7 days")
    expect(page).to have_css("li", text: "update the claim status from ‘Submitted’ to ‘Payment in progress’")
    expect(page).to have_css("div.govuk-warning-text", text: "This action cannot be undone.")
  end

  def when_i_click_on_send_claims
    click_on("Send claims")
  end

  def then_i_see_a_success_flash_message
    expect(page).to have_content("Claims sent to ESFA")
  end

  def and_claims_have_been_sent_to_esfa
    expect(Claims::Claim.submitted.count).to eq(0)
    expect(Claims::Claim.payment_in_progress.count).to eq(3)
  end
end
