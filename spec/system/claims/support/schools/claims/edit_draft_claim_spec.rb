require "rails_helper"

RSpec.describe "Edit a draft claim", type: :system, service: :claims do
  let!(:claims_mentor) { create(:claims_mentor, first_name: "Barry", last_name: "Garlow") }
  let!(:another_claims_mentor) { create(:claims_mentor, first_name: "Laura", last_name: "Clark") }

  let(:school) { create(:claims_school, name: "A School", region: regions(:inner_london), mentors: [claims_mentor, another_claims_mentor]) }
  let!(:colin) { create(:claims_support_user, :colin) }

  let!(:best_practice_network_provider) { create(:claims_provider, :best_practice_network) }
  let!(:niot_provider) { create(:claims_provider, :niot) }

  let!(:draft_claim) do
    create(
      :claim,
      :draft,
      school:,
      reference: "12345678",
      provider: best_practice_network_provider,
      submitted_by: colin,
    )
  end

  let!(:submitted_claim) do
    create(
      :claim,
      :submitted,
      school:,
      reference: "12345679",
      submitted_at: Time.new(2024, 3, 5, 12, 31, 52, "+00:00"),
      provider: best_practice_network_provider,
      submitted_by: colin,
    )
  end

  let!(:draft_mentor_training) { create(:mentor_training, claim: draft_claim, mentor: claims_mentor, hours_completed: 6) }
  let!(:submitted_mentor_training) { create(:mentor_training, claim: submitted_claim, mentor: claims_mentor, hours_completed: 6) }

  scenario "A support user I can edit a draft claim" do
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    when_i_select_a_school
    when_i_click_on_claims
    when_i_visit_the_draft_claim_show_page
    then_i_edit_the_provider
    then_i_edit_the_mentors
    then_i_edit_the_hours_of_training
    then_i_update_the_claim
  end

  scenario "A support user I can't edit a non draft claim" do
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    when_i_select_a_school
    when_i_click_on_claims
    then_i_cant_edit_the_submitted_claim
  end

  private

  def then_i_update_the_claim
    click_on("Update claim")
    expect(page).to have_content("Claim updated")
  end

  def then_i_edit_the_hours_of_training
    all("a", text: "Change")[2].click
    page.choose("Another amount")
    fill_in("Number of hours", with: 11)
    click_on("Continue")
    expect(page).to have_content("Barry Garlow11 hoursChange")
  end

  def then_i_edit_the_mentors
    all("a", text: "Change")[1].click
    page.check(another_claims_mentor.full_name)
    click_on("Continue")
    page.choose("20 hours")
    click_on("Continue")
    page.choose("20 hours")
    click_on("Continue")

    expect(page).to have_content("Laura Clark")
    expect(page).to have_content("Barry Garlow")
  end

  def then_i_edit_the_provider
    expect(page).to have_content("Accredited providerBest Practice NetworkChange")
    first("a", text: "Change").click
    page.choose(niot_provider.name)
    click_on("Continue")
    expect(page).to have_content("Accredited providerNIoT: National Institute of Teaching, founded by the School-Led Development TrustChange")
  end

  def when_i_visit_the_draft_claim_show_page
    click_on draft_claim.reference

    expect(page).to have_content("Best Practice NetworkChange")
    expect(page).to have_content("Barry Garlow\nChange")
    expect(page).to have_content("Barry Garlow#{draft_mentor_training.hours_completed} hoursChange")
  end

  def then_i_cant_edit_the_submitted_claim
    click_on submitted_claim.reference

    expect(page).not_to have_content("Best Practice NetworkChange")
    expect(page).not_to have_content("Barry Garlow\nChange")
    expect(page).not_to have_content("Barry Garlow#{submitted_mentor_training.hours_completed} hoursChange")
  end

  def when_i_select_a_school
    click_on "A School"
  end

  def when_i_click_on_claims
    within(".app-secondary-navigation__list") do
      click_on("Claims")
    end
  end

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end
end
