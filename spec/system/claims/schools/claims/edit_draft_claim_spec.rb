require "rails_helper"

RSpec.describe "Edit a claim", service: :claims, type: :system do
  let!(:claim_window) { create(:claim_window, :current) }
  let(:school) { create(:claims_school, name: "A School", region: regions(:inner_london), eligible_claim_windows: [claim_window]) }

  let(:anne) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end

  let(:provider) { create(:claims_provider, :best_practice_network) }
  let!(:another_provider) { create(:claims_provider, :niot) }
  let(:mentor) { create(:claims_mentor, first_name: "Barry", last_name: "Garlow", schools: [school]) }

  let!(:draft_claim) do
    create(:claim,
           :draft,
           school:,
           reference: "88888888",
           provider:,
           claim_window:)
  end

  scenario "Anne edits the hours of a draft claim to the maximum number of hours" do
    given_a_mentor_training_for(hours_completed: 6)
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    when_i_visit_the_claim_show_page(draft_claim)
    then_i_can_then_see_the_draft_claim_details(6)
    when_i_change_the_hours_of_training
    then_i_see_20_hours_of_training_remaining
    when_i_choose_hours("20 hours")
    and_i_click("Continue")
    then_i_see_the_check_your_answers_page(provider:, mentor:, hours_completed: 20)
    and_i_click("Accept and submit")
    then_i_see_the_claim_submitted_message
  end

  scenario "Anne edits the hours of a draft claim a custom number of hours" do
    given_a_mentor_training_for(hours_completed: 20)
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    when_i_visit_the_claim_show_page(draft_claim)
    then_i_can_then_see_the_draft_claim_details(20)
    when_i_change_the_hours_of_training
    then_i_see_20_hours_of_training_remaining
    when_i_choose_custom_hours(hours: 6)
    and_i_click("Continue")
    then_i_see_the_check_your_answers_page(provider:, mentor:, hours_completed: 6)
    and_i_click("Accept and submit")
    then_i_see_the_claim_submitted_message
  end

  scenario "Anne edits the draft claim without selecting a mentor" do
    given_a_mentor_training_for(hours_completed: 6)
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    when_i_visit_the_claim_show_page(draft_claim)
    then_i_can_then_see_the_draft_claim_details(6)

    when_i_click_to_change_mentors
    then_i_see_mentor_barry_garlow_selected

    when_i_unselect_mentor_barry_garlow
    and_i_click("Continue")
    then_i_see_a_validation_error_for_selecting_a_mentor
  end

  scenario "Anne submits the draft claim which is invalid", :js do
    given_a_mentor_training_for(hours_completed: 20)
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    when_i_visit_the_claim_show_page(draft_claim)
    then_i_can_then_see_the_draft_claim_details(20)

    and_i_click("Change Accredited provider")
    when_i_enter_a_provider_named_niot
    then_i_see_a_dropdown_item_for_niot

    when_i_click_the_dropdown_item_for_niot
    and_i_click("Continue") # To mentors step
    and_i_click("Continue") # To mentor training step
    and_i_click("Continue") # To check your answers
    then_i_see_the_check_your_answers_page(provider: another_provider, mentor:, hours_completed: 20)

    when_another_claim_has_been_submitted_for_provider_niot
    and_i_click("Accept and submit")
    then_i_see_i_can_not_sumbit_the_claim
  end

  private

  def given_a_mentor_training_for(hours_completed:)
    @draft_mentor_training = create(:mentor_training,
                                    claim: draft_claim,
                                    mentor:,
                                    hours_completed:,
                                    provider:,
                                    date_completed: claim_window.starts_on + 1.day)
  end

  def when_i_visit_the_claim_show_page(claim)
    click_on claim.reference
  end

  def then_i_can_then_see_the_draft_claim_details(number_of_hours)
    expect(page).to have_h1("Claim - #{draft_claim.reference}", class: "govuk-heading-l")
    expect(page).to have_summary_list_row("School", "A School")
    expect(page).to have_content("Draft")
    expect(page).not_to have_content("Submitted by")
    expect(page).to have_summary_list_row("Accredited provider", "Best Practice Network")

    expect(page).to have_summary_list_row("Mentors", "Barry Garlow")

    expect(page).to have_h2("Hours of training", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("Barry Garlow", "#{number_of_hours} hours")

    expect(page).to have_h2("Grant funding", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("Total hours", "#{number_of_hours} hours")
    expect(page).to have_summary_list_row("Hourly rate", "£53.60")

    amount = Money.new(number_of_hours * school.region.claims_funding_available_per_hour_pence, "GBP")
    expect(page).to have_summary_list_row(
      "Claim amount",
      amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    )
  end

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
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

  def when_i_choose_custom_hours(hours:)
    page.choose("Another amount")
    fill_in("Number of hours", with: hours)
  end

  def then_i_see_the_check_your_answers_page(provider:, mentor:, hours_completed:)
    expect(page).to have_summary_list_row("School", "A School")
    expect(page).not_to have_content("Submitted by")

    expect(page).to have_summary_list_row("Provider", provider.name)
    expect(page).to have_summary_list_row("Mentors", mentor.full_name)

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
                           provider: another_provider,
                           claim_window:)

    create(:mentor_training,
           claim: another_claim,
           mentor:,
           hours_completed: 20,
           provider: another_provider,
           date_completed: claim_window.starts_on + 1.day)
  end

  def then_i_see_i_can_not_sumbit_the_claim
    expect(page).to have_h1("You cannot submit the claim")
    expect(page).to have_content("You cannot submit the claim because your mentors’ information has recently changed.")
  end

  def when_i_enter_a_provider_named_niot
    fill_in "Enter the accredited provider", with: another_provider.name
  end

  def then_i_see_a_dropdown_item_for_niot
    expect(page).to have_css(".autocomplete__option", text: another_provider.name, wait: 10)
  end

  def when_i_click_the_dropdown_item_for_niot
    page.find(".autocomplete__option", text: another_provider.name).click
  end
end
