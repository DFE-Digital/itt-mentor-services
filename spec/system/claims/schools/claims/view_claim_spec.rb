require "rails_helper"

RSpec.describe "View a claim", service: :claims, type: :system do
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

  let!(:submitted_claim) do
    create(
      :claim,
      :submitted,
      school:,
      reference: "12345678",
      submitted_at: Time.new(2024, 3, 5, 12, 31, 52, "+00:00"),
      provider:,
      submitted_by: anne,
    )
  end

  let!(:draft_claim) do
    create(
      :claim,
      :draft,
      school:,
      reference: "88888888",
      provider:,
    )
  end

  let!(:mentor_training) { create(:mentor_training, claim: submitted_claim, mentor:, hours_completed: 6) }
  let!(:draft_mentor_training) { create(:mentor_training, claim: draft_claim, mentor:, hours_completed: 6) }

  before do
    given_there_is_a_current_claim_window
  end

  scenario "Anne visits the show page of a submitted claim" do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    when_i_visit_the_claim_show_page(submitted_claim)
    then_i_can_then_see_the_submitted_claim_details
    then_i_cant_see_submit_button
  end

  scenario "Anne visits the show page of a draft claim" do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    when_i_visit_the_claim_show_page(draft_claim)
    then_i_can_then_see_the_draft_claim_details
    then_i_can_see_submit_button
    when_i_click("Submit claim")
    then_i_can_see_submit_button
    then_i_can_then_see_the_draft_claim_details_without_change_buttons
  end

  private

  def when_i_visit_the_claim_show_page(claim)
    click_on claim.reference
  end

  def then_i_can_then_see_the_submitted_claim_details
    expect(page).to have_content("Claim - #{submitted_claim.reference}")
    expect(page).to have_content("SchoolA School")
    expect(page).to have_content("Academic year#{submitted_claim.academic_year.name}")
    expect(page).to have_content("Submitted")
    expect(page).to have_content("Submitted by #{anne.full_name} on 5 March 2024.")
    expect(page).to have_content("Accredited providerBest Practice Network")
    expect(page).to have_content("Mentors\nBarry Garlow")
    expect(page).to have_content("Hours of training")
    expect(page).to have_content("Barry Garlow#{mentor_training.hours_completed} hours")
    expect(page).to have_content("Total hours6 hours")
    expect(page).to have_content("Hourly rate£53.60")
    expect(page).to have_content("Claim amount£321.60")
    expect(page).not_to have_content("Change")
  end

  def then_i_can_then_see_the_draft_claim_details
    expect(page).to have_content("Claim - #{draft_claim.reference}")
    expect(page).to have_content("SchoolA School")
    expect(page).to have_content("Academic year#{draft_claim.academic_year.name}")
    expect(page).to have_content("Draft")
    expect(page).not_to have_content("Submitted by")
    expect(page).to have_content("Accredited providerBest Practice Network")
    expect(page).to have_content("Mentors\nBarry Garlow")
    expect(page).to have_content("Hours of training")
    expect(page).to have_content("Barry Garlow#{draft_mentor_training.hours_completed} hours")
    expect(page).to have_content("Total hours6 hours")
    expect(page).to have_content("Hourly rate£53.60")
    expect(page).to have_content("Claim amount£321.60")
    expect(page).to have_content("Change", count: 3)
  end

  def then_i_can_then_see_the_draft_claim_details_without_change_buttons
    expect(page).to have_content("Claim - #{draft_claim.reference}")
    expect(page).to have_content("SchoolA School")
    expect(page).to have_content("Academic year#{draft_claim.academic_year.name}")
    expect(page).not_to have_content("Submitted by")
    expect(page).to have_content("Accredited providerBest Practice Network")
    expect(page).to have_content("Mentors\nBarry Garlow")
    expect(page).to have_content("Hours of training")
    expect(page).to have_content("Barry Garlow#{draft_mentor_training.hours_completed} hours")
    expect(page).to have_content("Total hours6 hours")
    expect(page).to have_content("Hourly rate£53.60")
    expect(page).to have_content("Claim amount£321.60")
    expect(page).not_to have_content("Change")
  end

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_there_is_a_current_claim_window
    Claims::ClaimWindow::Build.call(claim_window_params: { starts_on: 2.days.ago, ends_on: 2.days.from_now }).save!(validate: false)
  end

  def then_i_cant_see_submit_button
    expect(page).not_to have_button("Submit claim")
  end

  def then_i_can_see_submit_button
    expect(page).to have_button("Submit claim")
  end

  def when_i_click(button)
    click_on button
  end
end
