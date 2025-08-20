require "rails_helper"

RSpec.describe "Create claim", :js, service: :claims, type: :system do
  let(:academic_year) do
    build(:academic_year,
          starts_on: Date.parse("1 September 2020"),
          ends_on: Date.parse("31 August 2021"),
          name: "2020 to 2021")
  end
  let!(:claim_window) { create(:claim_window, :current, academic_year:) }
  let!(:eligibility) { build(:eligibility, claim_window:) }
  let!(:school) do
    create(
      :claims_school,
      region: regions(:inner_london),
      eligibilities: [eligibility],
    )
  end
  let!(:mentor1) { create(:claims_mentor, first_name: "Anne", schools: [school]) }
  let!(:mentor2) { create(:claims_mentor, first_name: "Joe", schools: [school]) }
  let!(:colin) do
    create(
      :claims_support_user,
      :colin,
    )
  end
  let!(:bpn) { create(:claims_provider, :best_practice_network) }
  let!(:niot) { create(:claims_provider, :niot) }

  before do
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    given_there_is_a_current_claim_window
  end

  scenario "Colin creates a claim" do
    when_i_click(school.name)
    when_i_click_on_claims
    when_i_click("Add claim")
    and_i_enter_a_provider_named_best_practice_network
    then_i_see_a_dropdown_item_for_best_practice_network

    when_i_click_the_dropdown_item_for_best_practice_network
    when_i_click("Continue")
    when_i_select_all_mentors
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor1)
    when_i_add_training_hours("20 hours")
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor2)
    when_i_choose_other_amount_and_input_hours(12)
    when_i_click("Back")
    then_i_expect_the_training_hours_for(20, mentor1)
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor2)
    when_i_choose_other_amount_and_input_hours(12)
    when_i_click("Continue")
    then_i_check_my_answers
    when_i_click("Accept and submit")
    then_i_am_redirected_to_index_page_with_no_claim
    when_i_click_on_2020_to_2021
    then_i_see_the_new_claim
  end

  scenario "Colin attempts to create a claim but backs off before the check page" do
    when_i_click(school.name)
    when_i_click_on_claims
    when_i_click("Add claim")
    and_i_enter_a_provider_named_best_practice_network
    then_i_see_a_dropdown_item_for_best_practice_network

    when_i_click_the_dropdown_item_for_best_practice_network
    when_i_click("Continue")
    when_i_select_all_mentors
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor1)
    when_i_add_training_hours("20 hours")
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor2)
    when_i_click("Back")
    then_i_expect_the_training_hours_for(20, mentor1)
    when_i_click("Back")
    then_i_expect_the_mentors_to_be_checked([mentor1, mentor2])
    when_i_click("Back")
    then_i_expect_the_provider_to_be_checked(bpn)
    when_i_click("Back")
    then_i_expect_to_be_on_the_claims_index_page
  end

  scenario "Colin creates a claim with mentor training hours over the maximum limit per provider" do
    when_i_click(school.name)
    when_i_click_on_claims
    when_i_click("Add claim")
    and_i_enter_a_provider_named_best_practice_network
    then_i_see_a_dropdown_item_for_best_practice_network

    when_i_click_the_dropdown_item_for_best_practice_network
    when_i_click("Continue")
    when_i_select_all_mentors
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor1)
    when_i_add_training_hours("20 hours")
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor2)
    when_i_choose_other_amount_and_input_hours(12)
    when_i_click("Continue")
    then_i_check_my_answers
    when_another_claim_with_same_mentors_has_been_created([mentor1, mentor2])
    when_i_click("Accept and submit")
    then_i_get_the_reject_page
  end

  scenario "Colin does not fill the form correctly" do
    when_i_click(school.name)
    when_i_click_on_claims
    when_i_click("Add claim")
    when_i_click("Continue")
    then_i_see_the_error(
      "Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode",
    )

    and_i_enter_a_provider_named_best_practice_network
    then_i_see_a_dropdown_item_for_best_practice_network

    when_i_click_the_dropdown_item_for_best_practice_network
    when_i_click("Continue")
    when_i_click("Continue")
    then_i_see_the_error("Select a mentor")
    when_i_select_all_mentors
    when_i_click("Continue")
    when_i_click("Continue")
    then_i_see_the_error("Select the number of hours")
    when_i_choose_other_amount
    when_i_click("Continue")
    then_i_see_the_error("Enter the number of hours")
    when_i_choose_other_amount_and_input_hours(-1)
    when_i_click("Continue")
    then_i_see_the_error("Enter the number of hours between 1 and 20")
    when_i_choose_other_amount_and_input_hours(21)
    when_i_click("Continue")
    then_i_see_the_error("Enter the number of hours between 1 and 20")
    when_i_choose_other_amount_and_input_hours(0.5)
    when_i_click("Continue")
    then_i_see_the_error("Enter whole numbers only")
  end

  scenario "School attempts to create a claim when their mentors have all been claimed for" do
    given_my_school_has_fully_claimed_for_all_mentors_for_provider(bpn)
    when_i_click(school.name)
    when_i_click_on_claims
    when_i_click("Add claim")
    and_i_enter_a_provider_named_best_practice_network
    then_i_see_a_dropdown_item_for_best_practice_network

    when_i_click_the_dropdown_item_for_best_practice_network
    when_i_click("Continue")
    then_i_should_see_the_message("There are no mentors you can include in a claim because they have already had 20 hours of training claimed for with Best Practice Network.")
  end

  scenario "School attempts to create a claim then changes the provider to an invalid one" do
    given_my_school_has_fully_claimed_for_all_mentors_for_provider(bpn)
    when_i_click(school.name)
    when_i_click_on_claims
    when_i_click("Add claim")
    when_i_enter_a_provider_named_niot
    then_i_see_a_dropdown_item_for_niot

    when_i_click_the_dropdown_item_for_niot
    when_i_click("Continue")
    when_i_select_a_mentor(mentor1)
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor1)
    when_i_add_training_hours("20 hours")
    when_i_click("Continue")
    when_i_click("Change Provider")
    and_i_enter_a_provider_named_best_practice_network
    then_i_see_a_dropdown_item_for_best_practice_network

    when_i_click_the_dropdown_item_for_best_practice_network
    when_i_click("Continue")
    then_i_should_see_the_message("There are no mentors you can include in a claim because they have already had 20 hours of training claimed for with Best Practice Network.")
    when_i_click("Change the accredited provider")
    when_i_enter_a_provider_named_niot
    then_i_see_a_dropdown_item_for_niot

    when_i_click_the_dropdown_item_for_niot
    when_i_click("Continue")
    when_i_click("Continue")
    when_i_click("Continue")
    then_i_should_land_on_the_check_page
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_my_school_has_fully_claimed_for_all_mentors_for_provider(provider)
    school.mentors.find_each do |mentor|
      create(:mentor_training, :submitted, mentor:, provider:, hours_completed: 20)
    end
  end

  def given_there_is_a_current_claim_window
    Claims::ClaimWindow::Build.call(claim_window_params: { starts_on: 2.days.ago, ends_on: 2.days.from_now }).save!(validate: false)
  end

  def when_i_click(button)
    click_on(button)
  end

  def when_i_click_on_claims
    within(primary_navigation) do
      click_on("Claims")
    end
  end

  def when_i_choose_a_provider(provider)
    page.choose(provider.name)
  end

  def when_i_select_all_mentors
    page.check(mentor1.full_name)
    page.check(mentor2.full_name)
  end

  def when_i_select_a_mentor(mentor)
    page.check(mentor.full_name)
  end

  def then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor)
    expect(page).to have_content("How many hours of training did #{mentor.full_name} complete?")
  end

  def when_i_add_training_hours(radio_button)
    page.choose(radio_button)
  end

  def when_i_choose_other_amount
    page.choose("Another amount")
  end

  def when_i_choose_other_amount_and_input_hours(hours)
    page.choose("Another amount")
    fill_in("Number of hours", with: hours)
  end

  def then_i_check_my_answers
    expect(page).to have_h1("Check your answers", class: "govuk-heading-l")

    expect(page).to have_summary_list_row("Academic year", claim_window.academic_year_name)
    expect(page).to have_summary_list_row("Provider", bpn.name)
    expect(page).to have_summary_list_row(
      "Mentors",
      "#{mentor1.full_name}\n#{mentor2.full_name}",
    )

    expect(page).to have_h2("Hours of training", class: "govuk-heading-m")

    expect(page).to have_summary_list_row(mentor1.full_name, "20 hours")
    expect(page).to have_summary_list_row(mentor2.full_name, "12 hours")

    expect(page).to have_h2("Grant funding", class: "govuk-heading-m")

    expect(page).to have_summary_list_row("Total hours", "32 hours")
    expect(page).to have_summary_list_row("Hourly rate", "£53.60")
    expect(page).to have_summary_list_row("Claim amount", "£1,715.20")
  end

  def then_i_expect_the_training_hours_for(_hours, mentor)
    expect(page).to have_content("How many hours of training did #{mentor.full_name} complete?")
    find("#claims-add-claim-wizard-mentor-training-step-hours-to-claim-maximum-field", visible: :all).checked?
  end

  def then_i_am_redirected_to_index_page_with_no_claim
    within(".govuk-notification-banner--success") do
      expect(page).to have_content "Claim added"
    end

    expect(page).to have_paragraph("There are no claims for #{school.name}")
  end

  def when_i_click_on_2020_to_2021
    click_on "2020 to 2021"
  end

  def then_i_see_the_new_claim
    expect(page).to have_content(Claims::Claim.draft.first.reference)
  end

  def then_i_see_the_error(message)
    expect(page).to have_validation_error(message)
  end

  def when_another_claim_with_same_mentors_has_been_created(mentors)
    claim = create(:claim, :submitted, provider: bpn)
    mentors.each do |mentor|
      create(:mentor_training, claim:, hours_completed: 20, mentor:, provider: bpn)
    end
  end

  def then_i_get_the_reject_page
    expect(page).to have_content "You cannot submit the claim"
  end

  def then_i_should_see_the_message(message)
    expect(page).to have_content(message)
  end

  def then_i_should_land_on_the_check_page
    expect(page).to have_content "Check your answers before submitting your claim"
  end

  def then_i_expect_the_mentors_to_be_checked(mentors)
    mentors.each do |mentor|
      has_checked_field?("#claims-claim-mentor-ids-#{mentor.id}-field")
    end
  end

  def then_i_expect_the_provider_to_be_checked(provider)
    has_checked_field?("#claims-claim-provider-form-provider-id-#{provider.id}-field")
  end

  def then_i_expect_to_be_on_the_claims_index_page
    expect(page).to have_current_path(claims_school_claims_path(school))
  end

  def and_i_enter_a_provider_named_best_practice_network
    fill_in "Enter the accredited provider", with: "Best Practice Network"
  end

  def then_i_see_a_dropdown_item_for_best_practice_network
    expect(page).to have_css(".autocomplete__option", text: "Best Practice Network", wait: 10)
  end

  def when_i_click_the_dropdown_item_for_best_practice_network
    page.find(".autocomplete__option", text: "Best Practice Network").click
  end

  def then_i_expect_the_provider_to_be_prefilled_with_best_practice_network
    expect(page.find("#claims-add-claim-wizard-provider-step-id-field").value).to eq(
      "Best Practice Network",
    )
  end

  def when_i_enter_a_provider_named_niot
    fill_in "Enter the accredited provider", with: niot.name
  end

  def then_i_see_a_dropdown_item_for_niot
    expect(page).to have_css(".autocomplete__option", text: niot.name, wait: 10)
  end

  def when_i_click_the_dropdown_item_for_niot
    page.find(".autocomplete__option", text: niot.name).click
  end
end
