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

  let(:draft_mentor_training) do
    create(
      :mentor_training,
      claim: draft_claim,
      mentor: claims_mentor,
      hours_completed: 6,
      provider: best_practice_network_provider,
      date_completed: claim_window.starts_on + 1.day,
    )
  end

  before do
    draft_mentor_training
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    when_i_select_a_school
    when_i_click_on_claims
  end

  scenario "As a support user I can edit a draft claim", :js do
    when_i_visit_the_draft_claim_show_page
    then_i_edit_the_provider(
      current_provider: best_practice_network_provider,
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

  scenario "Anne edits the draft claim without selecting a mentor" do
    when_i_visit_the_draft_claim_show_page
    when_i_click_to_change_mentors
    then_i_see_mentor_barry_garlow_selected

    when_i_unselect_mentor_barry_garlow
    when_i_click("Continue")
    then_i_see_a_validation_error_for_selecting_a_mentor
  end

  scenario "Anne submits the draft claim which is invalid", :js do
    when_i_visit_the_draft_claim_show_page
    when_i_click("Change Accredited provider")
    when_i_enter_a_provider_named_niot
    then_i_see_a_dropdown_item_for_niot

    when_i_click_the_dropdown_item_for_niot
    when_i_click("Continue") # To mentors step
    when_i_click("Continue") # To mentor training step
    when_i_click("Continue") # To check your answers
    then_i_see_the_check_your_answers_page(
      provider: niot_provider,
      hours_completed: 6,
    )

    when_another_claim_has_been_submitted_for_provider_niot
    when_i_click("Update claim")
    then_i_see_i_can_not_submit_the_claim
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

  def then_i_edit_the_provider(current_provider:)
    expect(page).to have_content(current_provider.name)
    click_on "Change Accredited provider"
    when_i_enter_a_provider_named_niot
    then_i_see_a_dropdown_item_for_niot
    when_i_click_the_dropdown_item_for_niot
    click_on("Continue")
  end

  def when_i_visit_the_draft_claim_show_page
    click_on draft_claim.reference

    expect(page).to have_h1("Claim - #{draft_claim.reference}", class: "govuk-heading-l")
    expect(page).to have_summary_list_row("School", "A School")
    expect(page).to have_content("Draft")
    expect(page).not_to have_content("Submitted by")
    expect(page).to have_summary_list_row("Accredited provider", "Best Practice Network")

    expect(page).to have_summary_list_row("Mentors", "Barry Garlow")

    expect(page).to have_h2("Hours of training", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("Barry Garlow", "6 hours")

    expect(page).to have_h2("Grant funding", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("Total hours", "6 hours")
    expect(page).to have_summary_list_row("Hourly rate", "£53.60")

    amount = Money.new(6 * school.region.claims_funding_available_per_hour_pence, "GBP")
    expect(page).to have_summary_list_row(
      "Claim amount",
      amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    )
  end

  def then_i_cant_edit_the_submitted_claim
    click_on submitted_claim.reference

    expect(page).not_to have_link("Change Accredited provider")
    expect(page).not_to have_link("Change Mentors")
  end

  def when_i_select_a_school
    click_on "A School"
  end

  def when_i_click_on_claims
    within(primary_navigation) do
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

  def when_i_click_to_change_mentors
    click_on "Change Mentor"
  end

  def then_i_see_mentor_barry_garlow_selected
    expect(page).to have_checked_field("Barry Garlow")
  end

  def when_i_unselect_mentor_barry_garlow
    uncheck "Barry Garlow"
  end

  def then_i_see_a_validation_error_for_selecting_a_mentor
    expect(page).to have_validation_error("Select a mentor")
  end

  def and_i_select_provider_niot
    choose "NIoT: National Institute of Teaching, founded by the School-Led Development Trust"
  end

  def when_another_claim_has_been_submitted_for_provider_niot
    another_claim = create(:claim,
                           :submitted,
                           school:,
                           reference: "99999999",
                           provider: niot_provider,
                           claim_window:)

    create(:mentor_training,
           claim: another_claim,
           mentor: claims_mentor,
           hours_completed: 20,
           provider: niot_provider,
           date_completed: claim_window.starts_on + 1.day)
  end

  def then_i_see_i_can_not_submit_the_claim
    expect(page).to have_h1("You cannot submit the claim")
    expect(page).to have_content("You cannot submit the claim because your mentors’ information has recently changed.")
  end

  def then_i_see_the_check_your_answers_page(provider:, hours_completed:)
    expect(page).to have_h1("Check your answers before submitting your claim", class: "govuk-heading-l")

    expect(page).to have_summary_list_row("Provider", provider.name)

    expect(page).to have_summary_list_row("Mentors", "Barry Garlow")

    expect(page).to have_h2("Hours of training", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("Barry Garlow", "#{hours_completed} hours")

    expect(page).to have_h2("Grant funding", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("Total hours", "#{hours_completed} hours")
    expect(page).to have_summary_list_row("Hourly rate", "£53.60")

    amount = Money.new(hours_completed * school.region.claims_funding_available_per_hour_pence, "GBP")
    expect(page).to have_summary_list_row(
      "Claim amount",
      amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    )
  end

  def when_i_enter_a_provider_named_niot
    fill_in "Enter the accredited provider", with: niot_provider.name
  end

  def then_i_see_a_dropdown_item_for_niot
    expect(page).to have_css(".autocomplete__option", text: niot_provider.name, wait: 10)
  end

  def when_i_click_the_dropdown_item_for_niot
    page.find(".autocomplete__option", text: niot_provider.name).click
  end
end
