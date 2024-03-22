require "rails_helper"

RSpec.describe "View claims", type: :system, service: :claims do
  let!(:support_user) { create(:claims_support_user) }
  let(:provider) { create(:claims_provider) }
  let(:mentor) { create(:claims_mentor) }
  let!(:claim) do
    create(
      :claim,
      :submitted,
      provider:,
      mentors: [mentor],
    )
  end

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user visists a submitted claims show page" do
    when_i_visit_claim_index_page
    when_i_click_on_claim(claim)
    then_i_can_see_the_details_of_a_submitted_claim
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_claim_index_page
    click_on("Claims")
  end

  def when_i_click_on_claim(claim)
    click_on(claim.id)
  end

  def then_i_can_see_the_details_of_a_submitted_claim
    expect(page).to have_content("Claims")

    within(".govuk-summary-list__row:nth-child(1)") do
      expect(page).to have_content("Status")
      expect(page).to have_content("Submitted")
    end

    within(".govuk-summary-list__row:nth-child(2)") do
      expect(page).to have_content("Accredited provider")
      expect(page).to have_content(provider.name)
    end

    within(".govuk-summary-list__row:nth-child(3)") do
      expect(page).to have_content("Mentor 1")
      expect(page).to have_content(mentor.full_name)
    end
  end
end
