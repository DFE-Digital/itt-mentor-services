require "rails_helper"

RSpec.describe "Support user adds a claim in exceptional circumstances", service: :claims, type: :system do
  scenario do
    given_claim_windows_exist
    and_a_school_exists_which_was_eligible_in_the_past_claim_window
    and_providers_exist
    and_the_get_teacher_api_is_stubbed
    and_i_am_signed_in

    when_i_visit_the_claims_index_page
    and_i_click_on_add_claim
    then_i_see_the_exceptional_circumstances_page

    when_i_click_on_continue
    then_i_see_a_validation_error_that_i_must_confirm_exceptional_circumstances

    when_i_confirm_exceptional_circumstances
    and_i_click_on_continue
    then_i_see_the_claim_window_page

    when_i_click_on_continue
    then_i_see_a_validation_error_that_i_must_select_a_claim_window

    when_i_select_the_past_claim_window
    and_i_click_on_continue
    then_i_see_the_school_page

    when_i_enter_a_school_name
    and_i_click_on_continue
    then_i_see_the_school_options_page

    when_i_select_london_school
    and_i_click_on_continue
    then_i_see_the_provider_page

    when_i_enter_the_provider_name
    and_i_click_on_continue
    and_i_select_best_practice_network
    and_i_click_on_continue
    then_i_see_the_mentor_page

    when_i_click_on_add_a_mentor
    then_i_see_the_add_mentor_page

    when_i_enter_the_trn_and_date_of_birth_of_the_new_mentor
    and_i_click_on_continue
    then_i_see_the_confirm_mentor_details_page

    when_i_click_on_confirm_and_add_mentor
    then_i_see_the_mentor_page_with_the_first_new_mentor

    when_i_click_on_add_a_mentor
    and_i_enter_the_trn_and_date_of_birth_of_a_second_new_mentor
    and_i_click_on_continue
    and_i_click_on_confirm_and_add_mentor
    then_i_see_the_mentor_page_with_both_new_mentors

    when_i_select_all_three_mentors
    and_i_click_on_continue
    then_i_see_the_hours_page_for_edna_krabappel

    when_i_choose_another_amount
    and_i_enter_21_hours
    and_i_click_on_continue
    then_i_see_a_validation_error_that_the_hours_are_too_high

    when_i_enter_6_hours
    and_i_click_on_continue
    then_i_see_the_hours_page_for_joe_bloggs

    when_i_choose_the_maximum_hours
    and_i_click_on_continue
    then_i_see_the_hours_page_for_ned_flanders

    when_i_choose_the_maximum_hours
    and_i_click_on_continue
    then_i_see_the_confirmation_page

    when_i_check_the_confirmation_box
    and_i_click_on_continue
    then_i_see_the_claim_status_page

    when_i_click_on_continue
    then_i_see_a_validation_error_that_i_must_choose_a_claim_status

    when_i_choose_paid
    and_i_click_on_continue
    then_i_see_validation_errors_for_the_payment_details

    when_i_choose_paid_to_an_academy
    and_i_enter_a_date_paid_in_the_future
    and_i_click_on_continue
    then_i_see_a_validation_error_that_the_date_paid_must_be_in_the_past

    when_i_enter_a_date_paid_before_the_claim_window_opened
    and_i_click_on_continue
    then_i_see_a_validation_error_that_the_date_paid_is_before_the_claim_window

    when_i_enter_a_valid_date_paid
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page_for_a_paid_claim

    when_i_click_on_change_the_claim_status
    then_i_see_the_claim_status_page_with_the_paid_answers

    when_i_choose_submitted
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_accept_and_submit_claim
    then_i_see_the_claim_page_with_a_success_banner
    and_the_claim_was_submitted_in_the_past_claim_window
  end

  scenario "the claim has already been paid" do
    given_claim_windows_exist
    and_a_school_exists_which_was_eligible_in_the_past_claim_window
    and_providers_exist
    and_i_am_signed_in
    and_i_have_completed_the_journey_up_to_the_claim_status_step

    when_i_choose_paid
    and_i_choose_paid_to_a_local_authority
    and_i_enter_a_valid_date_paid
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page_for_a_paid_claim_paid_to_a_local_authority

    when_i_click_on_accept_and_submit_claim
    then_i_see_the_claim_page_for_a_paid_claim
    and_the_claim_was_created_as_paid_to_a_local_authority
    and_the_school_was_not_emailed
  end

  scenario "the support user goes back and cancels" do
    given_claim_windows_exist
    and_a_school_exists_which_was_eligible_in_the_past_claim_window
    and_providers_exist
    and_i_am_signed_in
    and_i_have_completed_the_journey_up_to_the_claim_status_step

    when_i_choose_paid
    and_i_choose_paid_to_an_academy
    and_i_enter_a_valid_date_paid
    and_i_click_on_continue
    and_i_click_on_the_back_link
    then_i_see_the_claim_status_page_with_the_paid_answers

    when_i_click_on_the_back_link
    then_i_see_the_confirmation_page_with_my_answer_kept

    when_i_click_on_cancel
    then_i_see_the_claims_index_page_without_a_new_claim
  end

  scenario "the support user sees the add exceptional claim button" do
    given_claim_windows_exist
    and_i_am_signed_in

    when_i_visit_the_claims_index_page
    then_i_see_the_add_exceptional_claim_button
  end

  scenario "the school is not eligible for the selected claim window" do
    given_claim_windows_exist
    and_a_school_exists_which_was_not_eligible_in_the_past_claim_window
    and_providers_exist
    and_i_am_signed_in

    when_i_visit_the_claims_index_page
    and_i_click_on_add_claim
    and_i_confirm_exceptional_circumstances
    and_i_click_on_continue
    and_i_select_the_past_claim_window
    and_i_click_on_continue
    and_i_enter_a_school_name
    and_i_click_on_continue
    and_i_select_london_school
    and_i_click_on_continue
    then_i_see_the_school_eligibility_page

    when_i_click_on_continue
    then_i_see_a_validation_error_that_i_must_confirm_the_school_is_made_eligible

    when_i_confirm_the_school_is_made_eligible
    and_i_click_on_continue
    and_i_enter_the_provider_name
    and_i_click_on_continue
    and_i_select_best_practice_network
    and_i_click_on_continue
    and_i_select_joe_bloggs
    and_i_click_on_continue
    and_i_choose_the_maximum_hours
    and_i_click_on_continue
    and_i_check_the_confirmation_box
    and_i_click_on_continue
    and_i_choose_submitted
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page_with_the_school_being_made_eligible

    when_i_click_on_accept_and_submit_claim
    then_the_school_was_made_eligible_and_the_claim_was_submitted
  end

  scenario "the school has not been onboarded to the claims service" do
    given_claim_windows_exist
    and_a_school_exists_which_has_not_been_onboarded
    and_providers_exist
    and_the_get_teacher_api_is_stubbed
    and_i_am_signed_in

    when_i_visit_the_claims_index_page
    and_i_click_on_add_claim
    and_i_confirm_exceptional_circumstances
    and_i_click_on_continue
    and_i_select_the_past_claim_window
    and_i_click_on_continue
    and_i_enter_a_school_name
    and_i_click_on_continue
    and_i_select_london_school
    and_i_click_on_continue
    then_i_see_the_school_onboarding_and_eligibility_page

    when_i_confirm_the_school_is_onboarded_and_made_eligible
    and_i_click_on_continue
    and_i_enter_the_provider_name
    and_i_click_on_continue
    and_i_select_best_practice_network
    and_i_click_on_continue
    then_i_see_the_no_mentors_page

    when_i_click_on_add_a_mentor
    and_i_enter_the_trn_and_date_of_birth_of_the_new_mentor
    and_i_click_on_continue
    and_i_click_on_confirm_and_add_mentor
    and_i_select_edna_krabappel
    and_i_click_on_continue
    and_i_choose_the_maximum_hours
    and_i_click_on_continue
    and_i_check_the_confirmation_box
    and_i_click_on_continue
    and_i_choose_submitted
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page_with_the_school_being_onboarded

    when_i_click_on_accept_and_submit_claim
    then_the_school_was_onboarded_and_the_claim_was_submitted
  end

  scenario "providers are chosen using the academic year of the selected claim window" do
    given_claim_windows_exist
    and_a_school_exists_which_was_eligible_in_the_past_claim_window
    and_providers_exist
    and_a_provider_exists_which_is_only_eligible_for_the_current_academic_year
    and_i_am_signed_in

    when_i_visit_the_claims_index_page
    and_i_click_on_add_claim
    and_i_confirm_exceptional_circumstances
    and_i_click_on_continue
    and_i_select_the_past_claim_window
    and_i_click_on_continue
    and_i_enter_a_school_name
    and_i_click_on_continue
    and_i_select_london_school
    and_i_click_on_continue
    and_i_enter_the_name_of_the_provider_only_eligible_for_the_current_academic_year
    and_i_click_on_continue
    then_i_see_no_provider_results

    when_i_click_on_the_back_link
    and_i_enter_the_provider_name
    and_i_click_on_continue
    then_i_see_the_provider_eligible_for_the_past_academic_year
  end

  scenario "a school user cannot use the tool" do
    given_claim_windows_exist
    and_a_school_exists_which_was_eligible_in_the_past_claim_window
    and_i_am_signed_in_as_a_school_user

    when_i_visit_the_add_claim_tool
    then_i_am_not_able_to_use_the_tool
  end

  private

  def given_claim_windows_exist
    @past_claim_window = create(:claim_window, :historic)
    @current_claim_window = Claims::ClaimWindow.current || create(:claim_window, :current, academic_year: AcademicYear.for_date(Date.current))
  end

  def and_a_school_exists_which_was_eligible_in_the_past_claim_window
    @mentor_joe = build(:claims_mentor, first_name: "Joe", last_name: "Bloggs")
    @school = create(
      :claims_school,
      name: "London School",
      mentors: [@mentor_joe],
      region: regions(:inner_london),
      eligibilities: [build(:eligibility, claim_window: @past_claim_window)],
    )
  end

  def and_a_school_exists_which_was_not_eligible_in_the_past_claim_window
    @school = create(
      :claims_school,
      name: "London School",
      mentors: [build(:claims_mentor, first_name: "Joe", last_name: "Bloggs")],
      region: regions(:inner_london),
      eligibilities: [build(:eligibility, claim_window: @current_claim_window)],
    )
  end

  def and_providers_exist
    @bpn_provider = create(:provider, :best_practice_network, accredited: false)
    @bpn_provider.eligibilities.create!(academic_year: @past_claim_window.academic_year)
    @niot_provider = create(:provider, :niot, accredited: false)
    @niot_provider.eligibilities.create!(academic_year: @past_claim_window.academic_year)
  end

  def and_the_get_teacher_api_is_stubbed
    allow(TeachingRecord::GetTeacher).to receive(:call)
      .with(trn: "7777777", date_of_birth: "1985-03-21")
      .and_return(
        "trn" => "7777777",
        "firstName" => "Ned",
        "middleName" => "",
        "lastName" => "Flanders",
        "dateOfBirth" => "1985-03-21",
      )
    allow(TeachingRecord::GetTeacher).to receive(:call)
      .with(trn: "6666666", date_of_birth: "1991-09-14")
      .and_return(
        "trn" => "6666666",
        "firstName" => "Edna",
        "middleName" => "",
        "lastName" => "Krabappel",
        "dateOfBirth" => "1991-09-14",
      )
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def and_i_am_signed_in_as_a_school_user
    sign_in_as(create(:claims_user, schools: [@school]))
  end

  def when_i_visit_the_claims_index_page
    visit claims_support_claims_path
  end

  def and_i_click_on_add_claim
    click_on "Add exceptional claim"
  end

  def then_i_see_the_exceptional_circumstances_page
    expect(page).to have_title("Exceptional circumstances - Add claim - exceptional circumstances - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_span_caption("Add claim - exceptional circumstances")
    expect(page).to have_h1("Only add a claim for a school in exceptional circumstances")
    expect(page).to have_warning_text("This tool is only for adding claims outside of a claim window. Do not use it for claims that the school can submit themselves.")
    expect(page).to have_field("I confirm that this claim is being added under exceptional circumstances", type: :checkbox)
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/support/claims")
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def then_i_see_a_validation_error_that_i_must_confirm_exceptional_circumstances
    expect(page).to have_validation_error("Confirm that this claim is being made under exceptional circumstances")
  end

  def when_i_confirm_exceptional_circumstances
    check "I confirm that this claim is being added under exceptional circumstances"
  end
  alias_method :and_i_confirm_exceptional_circumstances, :when_i_confirm_exceptional_circumstances

  def then_i_see_the_claim_window_page
    expect(page).to have_title("Select a claim window - Add claim - exceptional circumstances - Claim funding for mentor training - GOV.UK")
    expect(page).to have_element(:h1, text: "Select a claim window", class: "govuk-fieldset__heading")
    expect(page).to have_hint("Only claim windows that have already closed can be selected.")
    expect(page).to have_field("#{@past_claim_window.academic_year_name} academic year", type: :radio)
    expect(page).not_to have_field("#{@current_claim_window.academic_year_name} academic year", type: :radio)
  end

  def then_i_see_a_validation_error_that_i_must_select_a_claim_window
    expect(page).to have_validation_error("Select a claim window")
  end

  def when_i_select_the_past_claim_window
    choose "#{@past_claim_window.academic_year_name} academic year"
  end
  alias_method :and_i_select_the_past_claim_window, :when_i_select_the_past_claim_window

  def then_i_see_the_school_page
    expect(page).to have_element(:label, text: "Enter the school for this claim", class: "govuk-label govuk-label--l")
    expect(page).to have_hint("Enter a school name, unique reference number (URN) or postcode")
    expect(page).not_to have_text("must be eligible")
    expect(page).to have_span_caption("Add claim - exceptional circumstances")
  end

  def when_i_enter_a_school_name
    fill_in "Enter the school for this claim", with: "London School"
  end
  alias_method :and_i_enter_a_school_name, :when_i_enter_a_school_name

  def then_i_see_the_school_options_page
    expect(page).to have_element(:h1, text: "1 results found for 'London School'", class: "govuk-fieldset__heading")
    expect(page).to have_field("London School", type: :radio)
  end

  def when_i_select_london_school
    choose "London School"
  end
  alias_method :and_i_select_london_school, :when_i_select_london_school

  def then_i_see_the_school_eligibility_page
    expect(page).to have_title("London School is not eligible to claim - Add claim - exceptional circumstances - Claim funding for mentor training - GOV.UK")
    expect(page).to have_span_caption("Add claim - exceptional circumstances")
    expect(page).to have_h1("London School is not eligible to claim")
    expect(page).to have_paragraph("London School is not eligible to claim for the #{@past_claim_window.academic_year_name} academic year.")
    expect(page).to have_warning_text("Making a school eligible changes who can claim funding. Only do this if you have the approval to do so.")
    expect(page).to have_field("I confirm that London School should be made eligible to claim for the #{@past_claim_window.academic_year_name} academic year", type: :checkbox)
  end

  def then_i_see_a_validation_error_that_i_must_confirm_the_school_is_made_eligible
    expect(page).to have_validation_error("Confirm that the school should be made eligible to claim")
  end

  def when_i_confirm_the_school_is_made_eligible
    check "I confirm that London School should be made eligible to claim for the #{@past_claim_window.academic_year_name} academic year"
  end

  def and_i_select_joe_bloggs
    check "Joe Bloggs"
  end

  def and_i_choose_the_maximum_hours
    choose "20 hours"
  end

  def and_i_check_the_confirmation_box
    check "I have confirmed the number of training hours recorded in this claim with Best Practice Network"
  end

  def then_i_see_the_check_your_answers_page_with_the_school_being_made_eligible
    expect(page).to have_h1("Check your answers before submitting the claim")
    expect(page).to have_summary_list_row("Eligibility", "London School will be made eligible for the #{@past_claim_window.academic_year_name} academic year")
  end

  def then_the_school_was_made_eligible_and_the_claim_was_submitted
    expect(@school.reload.eligibilities.map(&:academic_year)).to include(@past_claim_window.academic_year)
    expect(Claims::Claim.last).to have_attributes(status: "submitted", claim_window: @past_claim_window, school_id: @school.id)
  end

  def and_a_school_exists_which_has_not_been_onboarded
    @school = create(:school, name: "London School", claims_service: false, region: regions(:inner_london))
  end

  def then_i_see_the_school_onboarding_and_eligibility_page
    expect(page).to have_h1("London School is not eligible to claim")
    expect(page).to have_paragraph("London School has not been onboarded to the claims service and is not eligible to claim for the #{@past_claim_window.academic_year_name} academic year.")
    expect(page).to have_field("I confirm that London School should be onboarded to the claims service and made eligible to claim for the #{@past_claim_window.academic_year_name} academic year", type: :checkbox)
  end

  def when_i_confirm_the_school_is_onboarded_and_made_eligible
    check "I confirm that London School should be onboarded to the claims service and made eligible to claim for the #{@past_claim_window.academic_year_name} academic year"
  end

  def then_i_see_the_no_mentors_page
    expect(page).to have_h1("No mentors for Best Practice Network")
    expect(page).to have_link("Add a mentor to the school")
  end

  def then_i_see_the_check_your_answers_page_with_the_school_being_onboarded
    expect(page).to have_summary_list_row("Eligibility", "London School will be onboarded to the claims service and made eligible for the #{@past_claim_window.academic_year_name} academic year")
  end

  def then_the_school_was_onboarded_and_the_claim_was_submitted
    school = Claims::School.find(@school.id)
    expect(school.claims_service).to be(true)
    expect(school.eligibilities.map(&:academic_year)).to include(@past_claim_window.academic_year)
    expect(Claims::Claim.last).to have_attributes(status: "submitted", claim_window: @past_claim_window, school_id: @school.id)
  end

  def and_i_have_completed_the_journey_up_to_the_claim_status_step
    visit claims_support_claims_path
    click_on "Add exceptional claim"
    check "I confirm that this claim is being added under exceptional circumstances"
    click_on "Continue"
    choose "#{@past_claim_window.academic_year_name} academic year"
    click_on "Continue"
    fill_in "Enter the school for this claim", with: "London School"
    click_on "Continue"
    choose "London School"
    click_on "Continue"
    fill_in "Enter the accredited provider for this claim", with: "Best Practice Network"
    click_on "Continue"
    choose "Best Practice Network"
    click_on "Continue"
    check "Joe Bloggs"
    click_on "Continue"
    choose "20 hours"
    click_on "Continue"
    check "I have confirmed the number of training hours recorded in this claim with Best Practice Network"
    click_on "Continue"
  end

  def then_i_see_the_claim_status_page
    expect(page).to have_title("Claim status - Add claim - exceptional circumstances - Claim funding for mentor training - GOV.UK")
    expect(page).to have_span_caption("Add claim - exceptional circumstances")
    expect(page).to have_element(:h1, text: "What is the status of this claim?", class: "govuk-fieldset__heading")
    expect(page).to have_field("Submitted", type: :radio)
    expect(page).to have_hint("The claim will be paid in the next payment run.")
    expect(page).to have_field("Paid", type: :radio)
    expect(page).to have_hint("The claim has already been paid.")
    expect(page).to have_field("Local authority", type: :radio)
    expect(page).to have_field("Academy", type: :radio)
    expect(page).to have_button("Continue")
    expect(page).to have_link("Back")
    expect(page).to have_link("Cancel", href: "/support/claims")
  end

  def then_i_see_a_validation_error_that_i_must_choose_a_claim_status
    expect(page).to have_validation_error("Select a claim status")
  end

  def when_i_choose_paid
    choose "Paid"
  end
  alias_method :and_i_choose_paid, :when_i_choose_paid

  def when_i_choose_submitted
    choose "Submitted"
  end
  alias_method :and_i_choose_submitted, :when_i_choose_submitted

  def then_i_see_validation_errors_for_the_payment_details
    expect(page).to have_validation_error("Select who the claim was paid to")
    expect(page).to have_validation_error("Enter the date the claim was paid")
  end

  def when_i_choose_paid_to_an_academy
    choose "Academy"
  end
  alias_method :and_i_choose_paid_to_an_academy, :when_i_choose_paid_to_an_academy

  def and_i_choose_paid_to_a_local_authority
    choose "Local authority"
  end

  def fill_in_date_paid(date)
    within_fieldset("Date paid") do
      fill_in "Day", with: date.day.to_s
      fill_in "Month", with: date.month.to_s
      fill_in "Year", with: date.year.to_s
    end
  end

  def and_i_enter_a_date_paid_in_the_future
    fill_in_date_paid(Date.current + 1.day)
  end

  def then_i_see_a_validation_error_that_the_date_paid_must_be_in_the_past
    expect(page).to have_validation_error("The date paid must be in the past")
  end

  def when_i_enter_a_date_paid_before_the_claim_window_opened
    fill_in_date_paid(@past_claim_window.starts_on - 1.day)
  end

  def then_i_see_a_validation_error_that_the_date_paid_is_before_the_claim_window
    expect(page).to have_validation_error("The date paid must not be before the claim window opened")
  end

  def when_i_enter_a_valid_date_paid
    @date_paid = @past_claim_window.starts_on + 1.day
    fill_in_date_paid(@date_paid)
  end
  alias_method :and_i_enter_a_valid_date_paid, :when_i_enter_a_valid_date_paid

  def then_i_see_the_check_your_answers_page_for_a_paid_claim
    expect(page).to have_h1("Check your answers before submitting the claim")
    expect(page).to have_summary_list_row("Claim status", "Paid")
    expect(page).to have_summary_list_row("Date paid", I18n.l(@date_paid, format: :long))
    expect(page).to have_summary_list_row("Paid to", "Academy")
  end

  def then_i_see_the_check_your_answers_page_for_a_paid_claim_paid_to_a_local_authority
    expect(page).to have_summary_list_row("Claim status", "Paid")
    expect(page).to have_summary_list_row("Date paid", I18n.l(@date_paid, format: :long))
    expect(page).to have_summary_list_row("Paid to", "Local authority")
  end

  def when_i_click_on_change_the_claim_status
    click_on "Change Claim status"
  end

  def then_i_see_the_claim_status_page_with_the_paid_answers
    expect(page).to have_checked_field("Paid")
    expect(page).to have_checked_field("Academy")
    within_fieldset("Date paid") do
      expect(page).to have_field("Day", with: @date_paid.day.to_s)
      expect(page).to have_field("Month", with: @date_paid.month.to_s)
      expect(page).to have_field("Year", with: @date_paid.year.to_s)
    end
  end

  def when_i_click_on_the_back_link
    click_on "Back"
  end
  alias_method :and_i_click_on_the_back_link, :when_i_click_on_the_back_link

  def then_i_see_the_confirmation_page_with_my_answer_kept
    expect(page).to have_h1("Confirm training hours with Best Practice Network")
    expect(page).to have_checked_field("I have confirmed the number of training hours recorded in this claim with Best Practice Network")
  end

  def when_i_click_on_cancel
    click_on "Cancel"
  end

  def then_i_see_the_claims_index_page_without_a_new_claim
    expect(page).to have_current_path("/support/claims")
    expect(Claims::Claim.count).to eq(0)
  end

  def then_i_see_the_claim_page_for_a_paid_claim
    claim = Claims::Claim.last
    expect(page).to have_current_path("/support/claims/#{claim.id}")
    expect(page).to have_success_banner("Claim added", "Claim #{claim.reference} has been submitted on behalf of London School.")
    expect(page).to have_summary_list_row("Date paid", I18n.l(@date_paid, format: :long))
    expect(page).to have_summary_list_row("Paid to", "Local authority")
  end

  def and_the_claim_was_created_as_paid_to_a_local_authority
    expect(Claims::Claim.last).to have_attributes(
      status: "paid", paid_to_la: true, date_paid: @date_paid.in_time_zone,
      claim_window: @past_claim_window, school_id: @school.id, provider_id: @bpn_provider.id
    )
  end

  def and_the_school_was_not_emailed
    expect(ActionMailer::Base.deliveries).to be_empty
    expect(Claims::Claim.awaiting_paid_notification).to be_empty
  end

  def then_i_see_the_add_exceptional_claim_button
    expect(page).to have_link("Add exceptional claim", href: "/support/claims/new")
    expect(page).not_to have_link("Add claim")
  end

  def and_a_provider_exists_which_is_only_eligible_for_the_current_academic_year
    @current_year_provider = create(:provider, name: "Current Year Provider", code: "CUR", accredited: true)
    @current_year_provider.eligibilities.destroy_all
    @current_year_provider.eligibilities.create!(academic_year: AcademicYear.current)
  end

  def and_i_enter_the_name_of_the_provider_only_eligible_for_the_current_academic_year
    fill_in "Enter the accredited provider for this claim", with: "Current Year Provider"
  end

  def then_i_see_no_provider_results
    expect(page).to have_text("No results found for 'Current Year Provider'")
    expect(page).not_to have_field("Current Year Provider", type: :radio)
  end

  def then_i_see_the_provider_eligible_for_the_past_academic_year
    expect(page).to have_element(:h1, text: "1 results found for 'Best Practice Network'", class: "govuk-fieldset__heading")
    expect(page).to have_field("Best Practice Network", type: :radio)
  end

  def then_i_see_the_provider_page
    expect(page).to have_element(:label, text: "Enter the accredited provider for this claim", class: "govuk-label govuk-label--l")
  end

  def when_i_enter_the_provider_name
    fill_in "Enter the accredited provider for this claim", with: "Best Practice Network"
  end
  alias_method :and_i_enter_the_provider_name, :when_i_enter_the_provider_name

  def and_i_select_best_practice_network
    choose "Best Practice Network"
  end

  def then_i_see_the_mentor_page
    expect(page).to have_title("Select mentors that trained with Best Practice Network - Add claim - exceptional circumstances - Claim funding for mentor training - GOV.UK")
    expect(page).to have_span_caption("Add claim - exceptional circumstances - London School")
    expect(page).to have_element(:h1, text: "Select mentors that trained with Best Practice Network", class: "govuk-fieldset__heading")
    expect(page).to have_field("Joe Bloggs", type: :checkbox)
  end

  def when_i_click_on_add_a_mentor
    click_on "Add a mentor to the school"
  end

  def then_i_see_the_add_mentor_page
    expect(page).to have_title("Enter a teacher reference number (TRN) - Add mentor - exceptional circumstances - Claim funding for mentor training - GOV.UK")
    expect(page).to have_span_caption("Add mentor - exceptional circumstances")
    expect(page).to have_h1("Find teacher")
    expect(page).to have_link("Cancel")
  end

  def when_i_enter_the_trn_and_date_of_birth_of_the_new_mentor
    fill_in "TRN", with: "6666666"
    within_fieldset("Date of birth") do
      fill_in "Day", with: "14"
      fill_in "Month", with: "9"
      fill_in "Year", with: "1991"
    end
  end
  alias_method :and_i_enter_the_trn_and_date_of_birth_of_the_new_mentor, :when_i_enter_the_trn_and_date_of_birth_of_the_new_mentor

  def then_i_see_the_confirm_mentor_details_page
    expect(page).to have_h1("Confirm mentor details")
    expect(page).to have_summary_list_row("First name", "Edna")
    expect(page).to have_summary_list_row("Last name", "Krabappel")
  end

  def when_i_click_on_confirm_and_add_mentor
    check "I confirm that Edna has been informed that the Department for Education will store their information in line with the privacy notice (opens in new tab) and have provided them with a copy of this notice for reference." if page.has_field?(type: :checkbox)
    click_on "Confirm and add mentor"
  end
  alias_method :and_i_click_on_confirm_and_add_mentor, :when_i_click_on_confirm_and_add_mentor

  def then_i_see_the_mentor_page_with_the_first_new_mentor
    expect(page).to have_success_banner("Mentor added", "Edna has been added to the school and can now be selected for this claim.")
    expect(page).to have_element(:h1, text: "Select mentors that trained with Best Practice Network", class: "govuk-fieldset__heading")
    expect(page).to have_field("Joe Bloggs", type: :checkbox)
    expect(page).to have_field("Edna Krabappel", type: :checkbox)
    expect(page).to have_link("Add a mentor to the school")
  end

  def then_i_see_the_mentor_page_with_both_new_mentors
    expect(page).to have_success_banner("Mentor added", "Ned has been added to the school and can now be selected for this claim.")
    expect(page).to have_field("Joe Bloggs", type: :checkbox)
    expect(page).to have_field("Edna Krabappel", type: :checkbox)
    expect(page).to have_field("Ned Flanders", type: :checkbox)
  end

  def and_i_enter_the_trn_and_date_of_birth_of_a_second_new_mentor
    fill_in "TRN", with: "7777777"
    within_fieldset("Date of birth") do
      fill_in "Day", with: "21"
      fill_in "Month", with: "3"
      fill_in "Year", with: "1985"
    end
  end

  def then_i_see_the_hours_page_for_ned_flanders
    expect(page).to have_element(:h1, text: "How many hours of training did Ned Flanders complete?", class: "govuk-fieldset__heading")
  end

  def when_i_select_all_three_mentors
    check "Joe Bloggs"
    check "Edna Krabappel"
    check "Ned Flanders"
  end

  def and_i_select_edna_krabappel
    check "Edna Krabappel"
  end

  def then_i_see_the_hours_page_for_joe_bloggs
    expect(page).to have_element(:h1, text: "How many hours of training did Joe Bloggs complete?", class: "govuk-fieldset__heading")
  end

  def when_i_choose_the_maximum_hours
    choose "20 hours"
  end

  def then_i_see_the_hours_page_for_edna_krabappel
    expect(page).to have_element(:h1, text: "How many hours of training did Edna Krabappel complete?", class: "govuk-fieldset__heading")
  end

  def when_i_choose_another_amount
    choose "Another amount"
  end

  def and_i_enter_21_hours
    fill_in "Number of hours", with: "21"
  end

  def then_i_see_a_validation_error_that_the_hours_are_too_high
    expect(page).to have_validation_error("Enter the number of hours between 1 and 20")
  end

  def when_i_enter_6_hours
    fill_in "Number of hours", with: "6"
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_h1("Confirm training hours with Best Practice Network")
  end

  def when_i_check_the_confirmation_box
    check "I have confirmed the number of training hours recorded in this claim with Best Practice Network"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers before submitting the claim - Add claim - exceptional circumstances - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Check your answers before submitting the claim")
    expect(page).to have_warning_text("This claim will be submitted on behalf of the school and cannot be changed once submitted.")
    expect(page).to have_summary_list_row("Academic year", "#{@past_claim_window.academic_year_name} (closed #{I18n.l(@past_claim_window.ends_on, format: :long)})")
    expect(page).to have_summary_list_row("School", "London School")
    expect(page).to have_summary_list_row("Provider", "Best Practice Network")
    expect(page).to have_summary_list_row("Joe Bloggs", "20 hours")
    expect(page).to have_summary_list_row("Edna Krabappel", "6 hours")
    expect(page).to have_summary_list_row("Ned Flanders", "20 hours")
    expect(page).to have_summary_list_row("Total hours", "46 hours")
    expect(page).to have_summary_list_row("Claim status", "Submitted")
    expect(page).not_to have_text("Date paid")
    expect(page).to have_button("Accept and submit claim")
  end

  def when_i_click_on_accept_and_submit_claim
    click_on "Accept and submit claim"
  end

  def then_i_see_the_claim_page_with_a_success_banner
    @claim = Claims::Claim.last
    expect(page).to have_success_banner("Claim added", "Claim #{@claim.reference} has been submitted on behalf of London School.")
    expect(page).to have_current_path("/support/claims/#{@claim.id}")
  end

  def and_the_claim_was_submitted_in_the_past_claim_window
    expect(@claim).to have_attributes(
      status: "submitted",
      claim_window: @past_claim_window,
      school: @school,
      provider_id: @bpn_provider.id,
    )
    expect(@claim.mentor_trainings.map(&:hours_completed)).to contain_exactly(20, 6, 20)
  end

  def when_i_visit_the_add_claim_tool
    visit new_add_claim_claims_support_claims_path
  end

  def then_i_am_not_able_to_use_the_tool
    expect(page).not_to have_h1("Only add a claim for a school in exceptional circumstances")
  end
end
