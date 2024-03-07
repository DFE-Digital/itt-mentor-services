require "rails_helper"

RSpec.describe "View a claim", type: :system, service: :claims do
  let(:school) { create(:claims_school, name: "A School") }

  let!(:colin) { create(:claims_support_user, :colin) }

  let!(:provider) { create(:provider, :best_practice_network) }
  let!(:claims_mentor) { create(:claims_mentor, first_name: "Barry", last_name: "Garlow") }

  let!(:claim) { create(:claim, school:, reference: "12345678", submitted_at: Time.new(2024, 3, 5, 12, 31, 52, "+00:00"), provider:) }
  let!(:mentor_training) { create(:mentor_training, claim:, mentor: claims_mentor, hours_completed: 6) }

  scenario "A support user visits the claims index page with a submited claim" do
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    when_i_select_a_school
    when_i_click_on_claims
    when_i_visit_the_claim_show_page
    then_i_can_then_see_the_claim_details
  end

  private

  def when_i_select_a_school
    click_on "A School"
  end

  def when_i_click_on_claims
    within(".app-secondary-navigation__list") do
      click_on("Claims")
    end
  end

  def when_i_visit_the_claim_show_page
    click_on claim.reference
  end

  def then_i_can_then_see_the_claim_details
    expect(page).to have_content("Claim - 12345678")
    expect(page).to have_content("SchoolA School")
    expect(page).to have_content("Accredited providerBest Practice Network")
    expect(page).to have_content("Mentors\nBarry Garlow")
    expect(page).to have_content("Date submitted05/03/2024")
    expect(page).to have_content("Hours of training")
    expect(page).to have_content("Status\nSubmitted")
    expect(page).to have_content("Barry Garlow#{mentor_training.hours_completed} hours")
    expect(page).to have_content("Claim amount£289.50")
  end

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end
end
