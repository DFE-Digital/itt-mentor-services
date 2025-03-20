require "rails_helper"

RSpec.describe "Change claim on check page", :js, service: :claims, type: :system do
  let!(:school) { create(:claims_school, mentors: [mentor1, mentor2, mentor3], region: regions(:inner_london)) }
  let!(:colin) do
    create(
      :claims_support_user,
      :colin,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end
  let!(:bpn) { create(:claims_provider, :best_practice_network) }
  let!(:niot) { create(:claims_provider, :niot) }

  let(:mentor1) { create(:mentor, first_name: "Anne") }
  let(:mentor2) { create(:mentor, first_name: "Joe") }
  let(:mentor3) { create(:mentor, first_name: "Joeana") }

  before do
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    given_there_is_a_current_claim_window
    when_i_click(school.name)
    when_i_click_on_claims

    when_i_click("Add claim")
    and_i_enter_a_provider_named_best_practice_network
    then_i_see_a_dropdown_item_for_best_practice_network

    when_i_click_the_dropdown_item_for_best_practice_network
    when_i_click("Continue")
    when_i_select_a_mentor(mentor1)
    when_i_select_a_mentor(mentor2)
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor1)
    when_i_add_training_hours("20 hours")
    when_i_click("Continue")
    then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor2)
    when_i_choose_other_amount_and_input_hours(12)
    when_i_click("Continue")
    then_i_check_my_answers(bpn, [mentor1, mentor2], [20, 12])
  end

  scenario "Colin changes the provider on claim on check page and doesn't need to add the mentor hours again" do
    when_i_click_change_provider
    then_i_expect_the_provider_to_be_prefilled_with_best_practice_network

    when_i_enter_a_provider_named_niot
    then_i_see_a_dropdown_item_for_niot

    when_i_click_the_dropdown_item_for_niot
    when_i_click("Continue")
    when_i_click("Continue") # Mentors step
    when_i_click("Continue") # Mentors 1 step
    when_i_click("Continue") # Mentors 2 step
    then_i_check_my_answers(niot, [mentor1, mentor2], [20, 12])
    when_i_click("Accept and submit")
    then_i_am_redirected_to_index_page
  end

  scenario "Colin changes the mentors on claim on check page" do
    when_i_click_change_mentors
    then_i_expect_the_mentors_to_be_checked([mentor1, mentor2])
    when_i_uncheck_the_mentors([mentor1, mentor2])
    when_i_click("Continue")
    then_i_see_the_error("Select a mentor")
    when_i_check_the_mentor(mentor2)
    when_i_click("Continue")
    when_i_click("Continue") # Mentors 2 step
    then_i_check_my_answers(
      bpn,
      [mentor2],
      [12],
    )
    when_i_click("Accept and submit")
    then_i_am_redirected_to_index_page
  end

  scenario "Colin changes the mentors on claim without inputting hours" do
    when_i_click_change_mentors
    then_i_expect_the_mentors_to_be_checked([mentor1, mentor2])
    when_i_check_the_mentor(mentor3)
    when_i_click("Continue")
    then_i_expect_the_training_hours_for(20, mentor1)
    when_i_click("Continue")
    then_i_expect_the_training_hours_for(12, mentor2)
    when_i_click("Continue")
    when_i_click("Continue") # I do not imput hours for Mentor 3
    then_i_see_the_error("Select the number of hours")
    when_i_add_training_hours("20 hours")
    when_i_click("Continue")
    then_i_check_my_answers(bpn, [mentor1, mentor2, mentor3], [20, 12, 20])
  end

  scenario "Colin changes the training hours for a mentor on check page" do
    when_i_click_change_training_hours_for_mentor
    then_i_expect_the_training_hours_to_be_selected(20)
    when_i_choose_other_amount
    when_i_click("Continue")
    then_i_see_the_error("Enter the number of hours")
    when_i_choose_other_amount_and_input_hours(6)
    when_i_click("Continue")
    when_i_click("Continue") # Mentor 2 step
    then_i_check_my_answers(bpn, [mentor1, mentor2], [6, 12])
  end

  scenario "Collin intends to change the training hours but clicks back link" do
    when_i_click_change_training_hours_for_mentor
    then_i_expect_the_training_hours_to_be_selected(20)
    when_i_click("Back")
    then_i_see_the_list_of_mentors
  end

  scenario "Collin click the back link on the check page" do
    when_i_click("Back")
    then_i_expect_the_training_hours_for(20, mentor2)
  end

  private

  def then_i_see_the_list_of_mentors
    expect(page).to have_content("#{mentor1.full_name}\n#{mentor1.trn}")
    expect(page).to have_content("#{mentor2.full_name}\n#{mentor2.trn}")
    expect(page).to have_content("#{mentor3.full_name}\n#{mentor3.trn}")
  end

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_there_is_a_current_claim_window
    @claim_window = create(:claim_window, :current)
  end

  def given_i_visit_claim_support_check_page
    visit check_claims_support_school_claim_path(school, claim)
  end

  def when_i_click_change_provider
    click_link("Change Provider")
  end

  def when_i_click_change_mentors
    click_link("Change Mentors")
  end

  def when_i_click_change_training_hours_for_mentor
    click_link("Change Hours of training for #{mentor1.full_name}")
  end

  def when_i_choose_other_amount
    page.choose("Another amount")
  end

  def when_i_choose_other_amount_and_input_hours(hours)
    page.choose("Another amount")
    fill_in("Number of hours", with: hours)
  end

  def then_i_expect_the_provider_to_be_checked(provider)
    has_checked_field?("#claim-provider-form-provider-id-#{provider.id}-field")
  end

  def then_i_expect_the_mentors_to_be_checked(mentors)
    mentors.each do |mentor|
      has_checked_field?("#claim-mentor-ids-#{mentor.id}-field")
    end
  end

  def when_i_click(button)
    click_on(button)
  end

  def when_i_change_the_provider
    page.choose(niot.name)
  end

  def when_i_uncheck_the_mentors(mentors)
    mentors.each do |mentor|
      uncheck(mentor.full_name)
    end
  end

  def when_i_check_the_mentor(mentor)
    check(mentor.full_name)
  end

  def when_i_add_training_hours(hours)
    choose(hours)
  end

  def then_i_expect_the_training_hours_to_be_selected(hours)
    if hours == 20
      find("#claims-add-claim-wizard-mentor-training-step-hours-to-claim-maximum-field", visible: :all).checked?
    else
      find("#claims-add-claim-wizard-mentor-training-step-hours-to-claim-custom-field", visible: :all).checked?
    end
  end

  def then_i_expect_the_training_hours_for(hours, mentor)
    expect(page).to have_content("How many hours of training did #{mentor.full_name} complete?")
    then_i_expect_the_training_hours_to_be_selected(hours)
  end

  def then_i_check_my_answers(provider, mentors, mentor_hours)
    expect(page).to have_h1("Check your answers before submitting your claim", class: "govuk-heading-l")

    expect(page).to have_summary_list_row("Academic year", @claim_window.academic_year_name)
    expect(page).to have_summary_list_row("Provider", provider.name)

    expect(page).to have_h2("Hours of training", class: "govuk-heading-m")

    mentors.each_with_index do |mentor, index|
      expect(page).to have_summary_list_row(mentor.full_name, mentor_hours[index])
    end

    expect(page).to have_h2("Grant funding", class: "govuk-heading-m")

    expect(page).to have_summary_list_row("Total hours", "#{mentor_hours.sum} hours")
    expect(page).to have_summary_list_row("Hourly rate", "£53.60")
    amount = Money.new(mentor_hours.sum * school.region.claims_funding_available_per_hour_pence, "GBP")
    expect(page).to have_summary_list_row(
      "Claim amount",
      amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    )
  end

  def then_i_cant_see_the_mentor(mentor)
    expect(page).not_to have_content(mentor.full_name)
  end

  def then_i_see_the_error(message)
    within(".govuk-error-summary") do
      expect(page).to have_content message
    end

    within(".govuk-form-group--error") do
      expect(page).to have_content message
    end
  end

  def then_i_am_redirected_to_index_page
    within(".govuk-notification-banner--success") do
      expect(page).to have_content "Claim added"
    end
  end

  def when_i_click_on_claims
    within(".app-secondary-navigation__list") do
      click_on("Claims")
    end
  end

  def when_i_choose_a_provider(provider)
    page.choose(provider.name)
  end

  def when_i_select_a_mentor(mentor)
    page.check(mentor.full_name)
  end

  def then_i_expect_to_be_able_to_add_training_hours_to_mentor(mentor)
    expect(page).to have_content("How many hours of training did #{mentor.full_name} complete?")
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
