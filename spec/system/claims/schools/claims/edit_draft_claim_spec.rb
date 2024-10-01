require "rails_helper"

RSpec.describe "Edit a claim", service: :claims, type: :system do
  let(:school) { create(:claims_school, name: "A School", region: regions(:inner_london)) }

  let(:anne) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end

  let(:provider) { build(:claims_provider, :best_practice_network) }
  let(:mentor) { build(:claims_mentor, first_name: "Barry", last_name: "Garlow") }

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

  before do
    given_there_is_a_current_claim_window
  end

  scenario "Anne visits the show page of a draft claim" do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    when_i_visit_the_claim_show_page(draft_claim)
    then_i_can_then_see_the_draft_claim_details(6)
    when_i_change_the_hours_of_training
    then_i_see_20_hours_of_training_remaining
    when_i_choose_hours("20 hours")
    and_i_click("Continue")
    and_i_click("Submit claim")
    then_i_see_the_claim_submitted_message
  end

  private

  def when_i_visit_the_claim_show_page(claim)
    click_on claim.reference
  end

  def then_i_can_then_see_the_draft_claim_details(number_of_hours)
    expect(page).to have_content("Claim - #{draft_claim.reference}")
    expect(page).to have_content("SchoolA School")
    expect(page).to have_content("Draft")
    expect(page).not_to have_content("Submitted by")
    expect(page).to have_content("Accredited providerBest Practice Network")
    expect(page).to have_content("Mentors\nBarry Garlow")
    expect(page).to have_content("Hours of training")
    expect(page).to have_content("Barry Garlow#{draft_mentor_training.hours_completed} hours")
    expect(page).to have_content("Total hours#{number_of_hours} hours")
    expect(page).to have_content("Hourly rate£53.60")
    expect(page).to have_content("Claim amount£321.60")
    expect(page).to have_content("Change", count: 3)
  end

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_there_is_a_current_claim_window
    Claims::ClaimWindow::Build.call(claim_window_params: { starts_on: 2.days.ago, ends_on: 2.days.from_now }).save!(validate: false)
  end

  def and_i_click(button)
    click_on button
  end

  def when_i_change_the_hours_of_training
    within("dl.govuk-summary-list:nth(2)") do
      within(".govuk-summary-list__row:nth(1)") do
        click_link("Change")
      end
    end
  end

  def then_i_see_20_hours_of_training_remaining
    expect(page).to have_content("Barry Garlow")
    expect(page).to have_content("20 hours")
  end

  def when_i_choose_hours(number_of_hours)
    page.choose(number_of_hours)
  end

  def then_i_see_the_claim_submitted_message
    expect(page).to have_content("Claim submitted")
    expect(page).to have_content(draft_claim.reference)
  end
end
