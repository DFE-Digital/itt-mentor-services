require "rails_helper"

RSpec.describe "Create claim", :js, service: :claims, type: :system do
  let!(:claim_window) { create(:claim_window, :current) }
  let(:mentor1) { build(:claims_mentor, first_name: "Anne") }
  let(:mentor2) { build(:claims_mentor, first_name: "Joe") }
  let(:school) { create(:claims_school, mentors: [mentor1, mentor2], region: regions(:inner_london), eligible_claim_windows: [claim_window]) }
  let!(:anne) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end
  let!(:bpn) { create(:claims_provider, :best_practice_network) }
  let!(:niot) { create(:claims_provider, :niot) }

  before do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
  end

  scenario "Anne creates a claim" do
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
    then_i_get_a_claim_reference_and_see_next_steps
  end

  scenario "Anne attempts to create a claim but backs off before the check page" do
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

  scenario "Anne creates a claim with mentor training hours over the maximum limit per provider" do
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

  scenario "Anne does not fill the form correctly" do
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
    when_i_click("Add claim")
    and_i_enter_a_provider_named_best_practice_network
    then_i_see_a_dropdown_item_for_best_practice_network

    when_i_click_the_dropdown_item_for_best_practice_network
    when_i_click("Continue")
    then_i_should_see_the_message("There are no mentors you can include in a claim because they have already had 20 hours of training claimed for with Best Practice Network.")
  end

  scenario "School attempts to create a claim then changes the provider to an invalid one" do
    given_my_school_has_fully_claimed_for_all_mentors_for_provider(bpn)
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

  context "when a claim has been created for the mentor in the previous year" do
    let(:claim) { build(:claim, :submitted, claim_window: build(:claim_window, :historic), provider: bpn) }
    let(:mentor_training) { create(:mentor_training, mentor: mentor1, provider: bpn, claim:, hours_completed: 20) }

    before do
      mentor_training
    end

    scenario "Anne creates a claim" do
      when_i_click("Add claim")
      and_i_enter_a_provider_named_best_practice_network
      then_i_see_a_dropdown_item_for_best_practice_network

      when_i_click_the_dropdown_item_for_best_practice_network
      when_i_click("Continue")
      when_i_select_a_mentor(mentor1)
      when_i_click("Continue")
      then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor1)
      and_the_total_claimable_hours_are_for_refresher_training
      when_i_add_training_hours("6 hours")
      when_i_click("Continue")
      then_i_should_land_on_the_check_page
      when_i_click("Accept and submit")
      then_i_get_a_claim_reference_and_see_next_steps
    end

    scenario "Anne creates a claim with more than the remaining hours" do
      when_i_click("Add claim")
      and_i_enter_a_provider_named_best_practice_network
      then_i_see_a_dropdown_item_for_best_practice_network

      when_i_click_the_dropdown_item_for_best_practice_network
      when_i_click("Continue")
      when_i_select_a_mentor(mentor1)
      when_i_click("Continue")
      then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor1)
      and_the_total_claimable_hours_are_for_refresher_training
      when_i_choose_other_amount_and_input_hours(7)
      when_i_click("Continue")
      then_i_see_the_error("Enter the number of hours between 1 and 6")
    end
  end

  context "when the school is ineligible to claim" do
    let(:school) { create(:claims_school, mentors: [mentor1, mentor2], region: regions(:inner_london)) }

    scenario "Anne creates a claim" do
      given_i_am_on_the_claims_index_page
      then_i_cannot_see_the_add_claim_button
      and_i_can_see_the_ineligible_to_claim_message
    end
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

  def when_i_click(button)
    click_on(button)
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

  def then_i_should_see_providers_ordered_by_name
    expect(page.body.index(bpn.name)).to be < page.body.index(niot.name)
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

  def then_i_get_a_claim_reference_and_see_next_steps
    claim = Claims::Claim.submitted.order(:submitted_at).last

    within(".govuk-panel") do
      expect(page).to have_content("Claim submitted\nYour reference number\n#{claim.reference}")
    end

    expect(page).to have_content("We have sent a copy of your claim to best_practice_network@example.com")
    expect(page).to have_content("You will automatically receive your payment from September #{Claims::ClaimWindow.current.academic_year.ends_on.year}.")
    expect(page).to have_content("Academies and independent schools will receive the payment directly. Maintained schools payments are made to their local authority.")
    expect(page).to have_content("If we need further information to process your claim we will email you.")
    expect(page).to have_content("We may check your claim")
    expect(page).to have_content("After payment we may check your claim to ensure it is accurate.")
    expect(page).to have_content("Best Practice Network will contact you if your claim undergoes a check.")
  end

  def then_i_expect_the_training_hours_for(_hours, mentor)
    expect(page).to have_content("How many hours of training did #{mentor.full_name} complete?")
    find("#claims-add-claim-wizard-mentor-training-step-hours-to-claim-maximum-field", visible: :all).checked?
  end

  def then_i_see_the_error(message)
    expect(page).to have_validation_error(message)
  end

  def given_i_visit_claim_check_page_after_submitting
    claim = Claims::Claim.submitted.order(:submitted_at).last

    Capybara.current_session.driver.header(
      "Referer",
      check_claims_school_claim_url(school, claim),
    )

    visit check_claims_school_claim_path(school, claim)
  end

  def then_i_am_redirected_to_root_path_with_alert
    expect(page).to have_current_path(claims_school_claims_path(school))
    expect(page).to have_content "You cannot perform this action"
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
    expect(page).to have_content "Check your answers"
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

  def and_the_total_claimable_hours_are_for_refresher_training
    expect(page).to have_content("6 hours")
    expect(page).to have_content("The remaining amount of hours for standard training")
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

  def when_i_enter_a_provider_named_niot
    fill_in "Enter the accredited provider", with: niot.name
  end

  def then_i_see_a_dropdown_item_for_niot
    expect(page).to have_css(".autocomplete__option", text: niot.name, wait: 10)
  end

  def when_i_click_the_dropdown_item_for_niot
    page.find(".autocomplete__option", text: niot.name).click
  end

  def then_i_expect_the_provider_to_be_prefilled_with_best_practice_network
    expect(page.find("#claims-add-claim-wizard-provider-step-id-field").value).to eq(
      "Best Practice Network",
    )
  end

  def given_i_am_on_the_claims_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(primary_navigation).to have_current_item("Claims")
  end

  def then_i_cannot_see_the_add_claim_button
    expect(page).not_to have_link("Add claim")
  end

  def and_i_can_see_the_ineligible_to_claim_message
    expect(page).to have_warning_text("You are not eligible to claim funding for mentor training as our records show you have not hosted placements for trainee teachers this academic year. Email ittmentor.funding@education.gov.uk if you have any queries.")
  end
end
