require "rails_helper"

RSpec.describe "View claims", service: :claims, type: :system do
  let!(:support_user) { create(:claims_support_user) }

  let!(:claim) { create(:claim, :payment_information_requested, unpaid_reason: "Some reason") }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
  end

  scenario "Support user visists a submitted claims show page" do
    given_i_sign_in
    when_i_visit_claims_payments_index_page
    when_i_click_on_claim(claim)
    then_i_can_see_the_details_of_claim(claim)
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

  def when_i_click_on_claim(claim)
    click_on(claim.school_name)
  end

  def then_i_can_see_the_details_of_claim(claim)
    expect(page).to have_content("Claim #{claim.reference}")
    expect(page).to have_content("Payer needs information")
    expect(page).to have_content("School#{claim.school_name}")
    expect(page).to have_content("Academic year#{claim.academic_year_name}")
    expect(page).to have_content("Accredited provider#{claim.provider_name}")

    within(".govuk-inset-text") do
      expect(page).to have_content("Some reason")
    end
  end
end
