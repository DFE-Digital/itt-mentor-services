require "rails_helper"

RSpec.describe "Submit a draft claim", type: :system, service: :claims do
  let(:school) { create(:claims_school, name: "A School", region: regions(:inner_london)) }

  let(:anne) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end

  let!(:provider) { create(:claims_provider, :best_practice_network) }
  let!(:mentor) { create(:claims_mentor, first_name: "Barry", last_name: "Garlow") }

  let!(:draft_claim) do
    create(
      :claim,
      :draft,
      school:,
      reference: "88888888",
      provider:,
    )
  end

  let!(:draft_mentor_training) { create(:mentor_training, claim: draft_claim, mentor:, hours_completed: 6) }

  scenario "Anne visits the show page of a draft claim" do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    when_i_visit_the_claim_show_page(draft_claim)
    then_i_can_then_see_the_draft_claim_details
    when_i_click_submit_button
    then_i_see_a_check_page_with_a_declaration
    when_i_click_submit_button
    then_i_get_a_claim_reference(draft_claim)
  end

  private

  def when_i_visit_the_claim_show_page(claim)
    click_on claim.reference
  end

  def then_i_can_then_see_the_draft_claim_details
    expect(page).to have_content("Claim - #{draft_claim.reference}")
    expect(page).to have_content("SchoolA School")
    expect(page).to have_content("Draft")
    expect(page).not_to have_content("Submitted by")
    expect(page).to have_content("Accredited providerBest Practice Network")
    expect(page).to have_content("Mentors\nBarry Garlow")
    expect(page).to have_content("Hours of training")
    expect(page).to have_content("Barry Garlow#{draft_mentor_training.hours_completed} hours")
    expect(page).to have_content("Total hours6 hours")
    expect(page).to have_content("Hourly rate£53.60")
    expect(page).to have_content("Claim amount£321.60")
  end

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_click_submit_button
    click_on "Submit claim"
  end

  def then_i_see_a_check_page_with_a_declaration
    expect(page).to have_content("Claim - #{draft_claim.reference}")
    expect(page).to have_content("Check your answers")
    expect(page).to have_content("Declaration")
    expect(page).to have_content("By submitting this claim, I confirm that:")
    expect(page).to have_content("I am authorised to claim on behalf of the school")
    expect(page).to have_content("I have read and accepted the grant terms and conditions")
    expect(page).to have_content("the information detailed above is accurate and the total I am claiming back has been used to support the cost of the mentor training")
    expect(page).to have_content("I will provide evidence to support this claim if requested by the Department for Education")
    expect(page).to have_content("You will not be able to change any of the claim details once you have submitted it.")
  end

  def then_i_get_a_claim_reference(claim)
    within(".govuk-panel") do
      expect(page).to have_content("Claim submitted\nYour reference number\n#{claim.reference}")
    end
  end
end
