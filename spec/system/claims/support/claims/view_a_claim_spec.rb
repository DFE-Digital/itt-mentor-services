require "rails_helper"

RSpec.describe "View claims", type: :system, service: :claims do
  let!(:support_user) { create(:claims_support_user) }
  let(:provider) { create(:provider) }
  let(:mentor) { create(:mentor) }
  let!(:claim_1) { create(:claim, draft: true) }
  let!(:claim_2) do
    create(
      :claim,
      draft: false,
      providers: [provider],
      mentors: [mentor],
    )
  end

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user visists a draft claims show page" do
    when_i_visit_claim_index_page
    and_i_click_on_claim(claim_1)
    i_can_see_the_details_of_a_draft_claim
  end

  scenario "Support user visists a submitted claims show page" do
    when_i_visit_claim_index_page
    and_i_click_on_claim(claim_2)
    i_can_see_the_details_of_a_submitted_claim
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_claim_index_page
    click_on("Claims")
  end

  def and_i_click_on_claim(claim)
    click_on(claim.id)
  end

  def i_can_see_the_details_of_a_draft_claim
    expect(page).to have_content("Claims")

    within(".govuk-summary-list__row:nth-child(1)") do
      expect(page).to have_content("Status")
      expect(page).to have_content("Draft")
    end

    within(".govuk-summary-list__row:nth-child(2)") do
      expect(page).to have_content("Provider")
      expect(page).to have_content("None")
    end

    within(".govuk-summary-list__row:nth-child(3)") do
      expect(page).to have_content("Mentor")
      expect(page).to have_content("None")
    end
  end

  def i_can_see_the_details_of_a_submitted_claim
    expect(page).to have_content("Claims")

    within(".govuk-summary-list__row:nth-child(1)") do
      expect(page).to have_content("Status")
      expect(page).to have_content("Submitted")
    end

    within(".govuk-summary-list__row:nth-child(2)") do
      expect(page).to have_content("Provider 1")
      expect(page).to have_content(provider.name)
    end

    within(".govuk-summary-list__row:nth-child(3)") do
      expect(page).to have_content("Mentor 1")
      expect(page).to have_content(mentor.full_name)
    end
  end
end
