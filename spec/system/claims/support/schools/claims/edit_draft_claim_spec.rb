require "rails_helper"

RSpec.describe "Edit a draft claim", service: :claims, type: :system do
  let!(:claim_window) { create(:claim_window, :current) }
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
      provider: best_practice_network_provider,
      reviewed: true,
      claim_window:,
    )
  end

  let!(:submitted_claim) do
    create(
      :claim,
      :submitted,
      school:,
      provider: best_practice_network_provider,
    )
  end

  let!(:draft_mentor_training) do
    create(
      :mentor_training,
      claim: draft_claim,
      mentor: claims_mentor,
      hours_completed: 6,
      date_completed: claim_window.starts_on + 1.day,
    )
  end

  before do
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    when_i_select_a_school
    when_i_click_on_claims
  end

  scenario "A support user I can edit a draft claim" do
    when_i_visit_the_draft_claim_show_page
    then_i_edit_the_provider(
      current_provider: best_practice_network_provider,
      new_provider: niot_provider,
    )
    then_i_edit_the_mentors
    then_i_edit_the_hours_of_training
    then_i_expect_the_current_draft_claims_to_not_have_my_changes
    when_i_click("Update claim")
    then_i_update_the_claim(another_claims_mentor)
  end

  scenario "A support user I can't edit a non draft claim" do
    then_i_cant_edit_the_submitted_claim
  end

  private

  def then_i_update_the_claim(mentor)
    expect(page).to have_content("Claim updated")
    expect(page).to have_content(mentor.full_name)
    expect(page).to have_content(
      "NIoT: National Institute of Teaching, founded by the "\
      "School-Led Development Trust",
    )
  end

  def then_i_edit_the_hours_of_training
    page.choose("Another amount")
    fill_in("Number of hours", with: 15)
    click_on("Continue")
  end

  def then_i_edit_the_mentors
    page.check(another_claims_mentor.full_name)
    click_on("Continue")
    page.choose("20 hours")
    click_on("Continue")
  end

  def then_i_edit_the_provider(current_provider:, new_provider:)
    expect(page).to have_content(current_provider.name)
    first("a", text: "Change").click
    page.choose(new_provider.name)
    click_on("Continue")
  end

  def when_i_visit_the_draft_claim_show_page
    click_on draft_claim.reference

    expect(page).to have_content("Best Practice Network")
    expect(page).to have_content("Barry Garlow")
    expect(page).to have_content("Barry Garlow#{draft_mentor_training.hours_completed} hours")
  end

  def then_i_cant_edit_the_submitted_claim
    click_on submitted_claim.reference
    change_links = all("a", text: "Change")

    expect(change_links).to be_empty
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

  def then_i_expect_the_current_draft_claims_to_not_have_my_changes
    mentor_names = Claims::Claim.active.flat_map(&:mentors).map(&:full_name)

    expect(mentor_names.include?(another_claims_mentor.full_name)).to be(false)
  end

  def when_i_go_back_to_the_check_page
    claim = Claims::Claim.active.draft.first
    visit check_claims_support_school_claim_path(claim.school, claim)
  end

  def then_i_expect_to_not_have_duplicated_claims
    uniq_references = Claims::Claim.active.pluck(:reference).uniq
    expect(Claims::Claim.active.count).to eq(uniq_references.count)
  end

  def when_i_click(button)
    click_on(button)
  end
end
