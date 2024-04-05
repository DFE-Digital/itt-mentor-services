require "rails_helper"

RSpec.describe "View claims", type: :system, service: :claims do
  let!(:support_user) { create(:claims_support_user) }
  let!(:claim_2) { create(:claim, :submitted) }
  let!(:claim_1) { create(:claim, :draft) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user visits the claims index page" do
    when_i_visit_claim_index_page
    then_i_see_a_list_of_submitted_claims
    and_i_see_no_draft_claims
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_claim_index_page
    click_on("Claims")
  end

  def then_i_see_a_list_of_submitted_claims
    within(".claim-card:nth-child(1)") do
      expect(page).to have_content(claim_2.school.name)
      expect(page).to have_content(claim_2.reference)
      expect(page).to have_content("Submitted")
      expect(page).to have_content(claim_2.provider.name)
      expect(page).to have_content(I18n.l(claim_2.created_at.to_date, format: :short))
      expect(page).to have_content(claim_2.amount.format(no_cents_if_whole: true))
    end
  end

  def and_i_see_no_draft_claims
    expect(page).not_to have_content(claim_1.reference)
  end
end
