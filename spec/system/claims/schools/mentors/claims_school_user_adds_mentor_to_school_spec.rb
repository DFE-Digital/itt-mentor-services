require "rails_helper"

RSpec.describe "Claims school user adds mentors to schools", service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists_with_an_assigned_mentor_and_an_unassigned_one
    and_given_the_get_teacher_api_is_stubbed
    and_i_am_signed_in
    and_i_navigate_to_mentors
    then_i_see_the_mentors_index_page

    when_i_click_on_add_mentor
    then_i_see_the_add_mentor_page

    when_i_click_on_back
    then_i_see_the_mentors_index_page

    when_i_click_on_add_mentor
    then_i_see_the_add_mentor_page

    when_i_click_cancel
    then_i_see_the_mentors_index_page

    when_i_click_on_add_mentor
    then_i_see_the_add_mentor_page

    when_i_click_on_the_help_text
    then_i_see_link_to_trn_guidance

    when_i_navigate_to_mentors
    and_i_click_on_add_mentor
    and_i_click_on_continue
    then_i_see_a_validation_error_that_i_must_add_a_trn_and_date_of_birth

    when_i_enter_an_invalid_trn
    and_i_click_on_continue
    then_i_see_a_validation_error_that_i_must_enter_a_seven_digit_trn

    when_i_enter_the_trn_and_dob_of_an_existing_mentor_at_this_school
    and_i_click_on_continue
    then_i_see_a_validation_error_that_the_mentor_is_already_added

    when_i_enter_the_trn_of_an_existing_mentor_not_at_this_school
    and_i_enter_the_wrong_date_of_birth
    and_i_click_on_continue
    then_i_see_the_no_results_page

    when_i_navigate_to_mentors
    and_i_click_on_add_mentor
    then_i_see_the_add_mentor_page

    when_i_enter_the_trn_of_an_existing_mentor_not_at_this_school
    and_i_enter_the_correct_date_of_birth
    and_i_click_on_continue
    then_i_see_the_check_details_page_for_the_new_mentor

    when_i_click_on_back
    then_i_see_the_add_mentor_page_with_persisted_details

    when_i_click_on_continue
    then_i_see_the_check_details_page_for_the_new_mentor

    when_i_click_on_confirm_and_add_mentor
    then_i_see_the_success_page_for_the_addition_of_the_new_mentor
  end

  def given_an_eligible_school_exists_with_an_assigned_mentor_and_an_unassigned_one
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor_james =  build(:claims_mentor, first_name: "James", last_name: "Jameson", trn: "4230187")
    @mentor_barry =  build(:claims_mentor, first_name: "Barry", last_name: "Garlow", trn: "3078146")
    @mentor_sam = build(:claims_mentor, first_name: "Sam", last_name: "Pete")
    @claim_window = build(:claim_window, :current)
    @shelbyville_school = create(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligible_claim_windows: [@claim_window],
      mentors: [@mentor_james],
    )
  end

  def and_given_the_get_teacher_api_is_stubbed
    allow(TeachingRecord::GetTeacher).to receive(:call)
    .with(trn: "3078146", date_of_birth: "1992-03-12")
    .and_raise TeachingRecord::RestClient::TeacherNotFoundError
    allow(TeachingRecord::GetTeacher).to receive(:call)
    .with(trn: "4230187", date_of_birth: "1999-11-12")
    .and_return teaching_record_valid_response(@mentor_james, "1999-11-12")
    allow(TeachingRecord::GetTeacher).to receive(:call)
    .with(trn: "3078146", date_of_birth: "1999-11-12")
    .and_return teaching_record_valid_response(@mentor_barry, "1999-11-12")
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def when_i_navigate_to_mentors
    within primary_navigation do
      click_on "Mentors"
    end
  end
  alias_method :and_i_navigate_to_mentors, :when_i_navigate_to_mentors

  def then_i_see_the_mentors_index_page
    expect(page).to have_title("Mentors - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("Mentors")
    expect(page).to have_link("Add mentor", href: "/schools/#{@shelbyville_school.id}/mentors/new")
    expect(page).to have_table_row("Name" => "James Jameson",
                                   "Teacher reference number (TRN)" => "4230187")
  end

  def when_i_click_on_add_mentor
    click_on "Add mentor"
  end
  alias_method :and_i_click_on_add_mentor, :when_i_click_on_add_mentor

  def then_i_see_the_add_mentor_page
    expect(page).to have_title("Enter a teacher reference number (TRN) - Mentor details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_span_caption("Mentor details")
    expect(page).to have_h1("Find teacher")
    expect(page).to have_hint("A TRN is a 7 digit number that uniquely identifies people in the education sector in England.")
    expect(page).to have_element(:input, id: "claims-add-mentor-wizard-mentor-step-trn-field")
    expect(page).to have_element(:input, id: "claims_add_mentor_wizard_mentor_step_date_of_birth_1i")
    expect(page).to have_element(:input, id: "claims_add_mentor_wizard_mentor_step_date_of_birth_2i")
    expect(page).to have_element(:input, id: "claims_add_mentor_wizard_mentor_step_date_of_birth_3i")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def when_i_click_cancel
    click_on "Cancel"
  end

  def when_i_click_on_the_help_text
    find(
      "span",
      text: "Help with the TRN",
    ).click
  end

  def then_i_see_link_to_trn_guidance
    expect(page).to have_text "If your mentor does not have a TRN, share the teacher reference number (TRN) guidance (opens in new tab) to find a lost TRN, or apply for one."
    expect(page).to have_link("teacher reference number (TRN) guidance (opens in new tab)", href: "https://www.gov.uk/guidance/teacher-reference-number-trn")
  end

  def then_i_see_a_validation_error_that_i_must_add_a_trn_and_date_of_birth
    expect(page).to have_validation_error("Enter a teacher reference number (TRN)")
    expect(page).to have_validation_error("Enter a date of birth")
  end

  def when_i_enter_an_invalid_trn
    fill_in "TRN", with: "123"
  end

  def then_i_see_a_validation_error_that_i_must_enter_a_seven_digit_trn
    expect(page).to have_validation_error("Enter a 7 digit teacher reference number (TRN)")
    expect(page).to have_validation_error("Enter a date of birth")
  end

  def when_i_enter_the_trn_and_dob_of_an_existing_mentor_at_this_school
    fill_in "TRN", with: "4230187"
    within_fieldset("Date of birth") do
      fill_in("Day", with: "12")
      fill_in("Month", with: "11")
      fill_in("Year", with: "1999")
    end
  end

  def then_i_see_a_validation_error_that_the_mentor_is_already_added
    expect(page).to have_validation_error("The mentor has already been added")
  end

  def when_i_enter_the_trn_of_an_existing_mentor_not_at_this_school
    fill_in "TRN", with: "3078146"
  end

  def and_i_enter_the_wrong_date_of_birth
    within_fieldset("Date of birth") do
      fill_in("Day", with: "12")
      fill_in("Month", with: "03")
      fill_in("Year", with: "1992")
    end
  end

  def then_i_see_the_no_results_page
    expect(page).to have_title("No results found for ‘3078146’ - Mentor details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_span_caption("Mentor details")
    expect(page).to have_h1("No results found for ‘3078146’")
    expect(page).to have_text("Check that you typed in the teacher reference number (TRN) correctly.")
    expect(page).to have_link("Change your search")
    expect(page).to have_link("Cancel")
  end

  def and_i_enter_the_correct_date_of_birth
    within_fieldset("Date of birth") do
      fill_in("Day", with: "12")
      fill_in("Month", with: "11")
      fill_in("Year", with: "1999")
    end
  end

  def then_i_see_the_check_details_page_for_the_new_mentor
    expect(page).to have_title("Confirm mentor details - Mentor details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_span_caption("Mentor details")
    expect(page).to have_h1("Confirm mentor details")
    expect(page).to have_summary_list_row("First name", "Barry")
    expect(page).to have_summary_list_row("Last name", "Garlow")
    expect(page).to have_summary_list_row("Teacher reference number (TRN)", "3078146")
    expect(page).to have_summary_list_row("Date of birth", "12/11/1999")
    expect(page).to have_button("Confirm and add mentor")
    expect(page).to have_link("Cancel")
  end

  def and_i_click_on_back
    click_on "Back"
  end
  alias_method :when_i_click_on_back, :and_i_click_on_back

  def then_i_see_the_add_mentor_page_with_persisted_details
    expect(page).to have_title("Enter a teacher reference number (TRN) - Mentor details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_span_caption("Mentor details")
    expect(page).to have_h1("Find teacher")
    expect(page).to have_hint("A TRN is a 7 digit number that uniquely identifies people in the education sector in England.")
    expect(page).to have_element(:input, id: "claims-add-mentor-wizard-mentor-step-trn-field")
    expect(page).to have_element(:input, id: "claims_add_mentor_wizard_mentor_step_date_of_birth_1i")
    expect(page).to have_element(:input, id: "claims_add_mentor_wizard_mentor_step_date_of_birth_2i")
    expect(page).to have_element(:input, id: "claims_add_mentor_wizard_mentor_step_date_of_birth_3i")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def and_i_click_on_confirm_and_add_mentor
    click_on "Confirm and add mentor"
  end
  alias_method :when_i_click_on_confirm_and_add_mentor, :and_i_click_on_confirm_and_add_mentor

  def teaching_record_valid_response(mentor, date_of_birth)
    {
      "trn" => mentor.trn.to_s,
      "firstName" => mentor.first_name.to_s,
      "middleName" => "",
      "lastName" => mentor.last_name.to_s,
      "dateOfBirth" => date_of_birth,
    }
  end

  def then_i_see_the_success_page_for_the_addition_of_the_new_mentor
    expect(page).to have_success_banner("Mentor added")
    expect(page).to have_title("Mentors - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("Mentors")
    expect(page).to have_link("Add mentor", href: "/schools/#{@shelbyville_school.id}/mentors/new")
    expect(page).to have_table_row("Name" => "James Jameson",
                                   "Teacher reference number (TRN)" => "4230187")
    expect(page).to have_table_row("Name" => "Barry Garlow",
                                   "Teacher reference number (TRN)" => "3078146")
  end
end
