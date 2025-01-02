require "rails_helper"

RSpec.describe "Reject claim payment", service: :claims, type: :system do
  let(:support_user) { create(:claims_support_user) }

  let!(:claim) { create(:claim, :payment_information_sent) }

  scenario "Support user rejects claim payment" do
    given_i_sign_in_as(support_user)

    given_i_visit_a_claim_show_page(claim)
    when_i_click_on_reject
    then_i_see_a_confirmation_page

    when_i_click_on_reject_claim
    then_i_see_the_claim_rejected
  end

  private

  def given_i_visit_a_claim_show_page(claim)
    click_on("Claims")
    click_on("Payments")
    click_on(claim.school_name)
  end

  def when_i_click_on_reject
    click_on("Reject claim")
  end

  def then_i_see_a_confirmation_page
    expect(page).to have_content("Are you sure you want to reject the claim?")
    expect(page).to have_content("This will result in this claim not being paid.")
  end

  def when_i_click_on_reject_claim
    click_on("Reject claim")
  end

  def then_i_see_the_claim_rejected
    expect(page).to have_content("Claim rejected")

    within("h1.govuk-heading-l .govuk-tag") do
      expect(page).to have_content("Payment not approved")
    end
  end
end
