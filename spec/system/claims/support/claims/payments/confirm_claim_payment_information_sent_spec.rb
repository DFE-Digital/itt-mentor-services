require "rails_helper"

RSpec.describe "Confirm claim payment information sent", service: :claims, type: :system do
  let(:support_user) { create(:claims_support_user) }

  let!(:claim) { create(:claim, :payment_information_requested) }

  scenario "Support user confirms claim payment information sent" do
    given_i_sign_in_as(support_user)

    given_i_visit_a_claim_show_page(claim)
    when_i_click_on_confirm_information_sent
    then_i_see_a_confirmation_page

    when_i_click_on_update_claim
    then_i_see_the_claim_updated
  end

  private

  def given_i_visit_a_claim_show_page(claim)
    click_on("Claims")
    click_on("Payments")
    click_on(claim.school_name)
  end

  def when_i_click_on_confirm_information_sent
    click_on("Confirm information sent")
  end

  def then_i_see_a_confirmation_page
    expect(page).to have_content("Are you sure you want to update the claim?")
    expect(page).to have_content("You confirm that you have sent the payer the information they requested so they can pay the claim.")
  end

  def when_i_click_on_update_claim
    click_on("Update claim")
  end

  def then_i_see_the_claim_updated
    expect(page).to have_content("Claim updated")

    within("h1.govuk-heading-l .govuk-tag") do
      expect(page).to have_content("Information sent")
    end
  end
end
