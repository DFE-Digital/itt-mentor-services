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
    expect(page).to have_content("ID")
    expect(page).to have_content("Status")
    expect(page).to have_selector("tbody tr", count: 1)

    expect(page).not_to have_selector("td", text: claim_1.id)

    within("tbody tr:nth-child(1)") do
      expect(page).to have_selector("td", text: claim_2.id)
      expect(page).to have_selector("td", text: "Submitted")
    end
  end
end
