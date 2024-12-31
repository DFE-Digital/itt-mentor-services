require "rails_helper"

RSpec.describe "School user searches for a mentor with no results", service: :placements, type: :system do
  before do
    stub_no_results_teaching_record_response
  end

  scenario do
    given_mentor_and_school_exists
    and_i_am_signed_in

    when_i_am_on_the_mentors_index_page
    then_i_see_the_mentor_details

    when_i_click_on_add_mentor
    then_i_see_the_find_mentor_page

    when_i_click_on_help_with_the_trn
    then_i_see_link_to_trn_guidance

    # user does not enter any data
    when_i_click_on_continue
    then_i_see_a_validation_error_for_not_entering_any_data

    # user only enters date of birth
    when_i_enter_a_date_of_birth
    and_i_click_on_continue
    then_i_see_a_validation_error_for_not_entering_a_trn

    # user only enters trn
    when_i_clear_the_date_of_birth
    and_i_enter_a_trn
    and_i_click_on_continue
    then_i_see_a_validation_error_for_not_entering_a_date_of_birth

    when_i_enter_an_invalid_trn
    and_i_click_on_continue
    then_i_see_a_validation_error_for_not_entering_a_valid_trn

    when_i_enter_valid_data_that_does_not_exist_in_the_teaching_record_service
    and_i_click_on_continue
    then_i_see_the_no_results_page

    when_i_click_on_change_your_search
    then_i_see_the_find_mentor_form_with_the_trn_and_date_of_birth_prefilled
  end

  private

  def given_mentor_and_school_exists
    @school = create(:school, :placements, name: "Springfield Elementary")
  end

  def and_i_am_signed_in
    given_i_am_signed_in_as_a_placements_user(organisations: [@school])
  end

  def when_i_am_on_the_mentors_index_page
    within ".app-primary-navigation__nav" do
      click_on "Mentors"
    end
  end

  def then_i_see_the_mentor_details
    expect(page).to have_title("Mentors at your school - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")

    expect(page).to have_h1("Mentors at your school")
    expect(page).to have_element(:p, text: "Add mentors to be able to assign them to your placements.", class: "govuk-body")
    expect(page).to have_link("Add mentor", href: "/schools/#{@school.id}/mentors/new")
  end

  def when_i_click_on_add_mentor
    click_on "Add mentor"
  end

  def then_i_see_the_find_mentor_page
    expect(page).to have_title("Find teacher - Mentor details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")

    expect(page).to have_element(:span, text: "Mentor details", class: "govuk-caption-l")
    expect(page).to have_h1("Find teacher")
    expect(page).to have_element(:label, text: "Teacher reference number (TRN)", class: "govuk-label")
    expect(page).to have_element(:div, text: "A TRN is a 7 digit number that uniquely identifies people in the education sector in England.", class: "govuk-hint")
    expect(page).to have_element(:span, text: "Help with the TRN", class: "govuk-details__summary-text")
    expect(page).to have_element(:legend, text: "Date of birth", class: "govuk-fieldset__legend")
    expect(page).to have_element(:div, text: "For example, 31 3 1980", class: "govuk-hint")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/mentors")

    # to contrast with non-hidden state
    expect(page).not_to have_element(:div, text: "If you do not know a teacher’s TRN, you can ask them for it. They can find a lost TRN, or apply for a new one by following the instructions in the TRN guidance (opens in new tab).", class: "govuk-details__text")
  end

  def when_i_click_on_help_with_the_trn
    find("span", text: "Help with the TRN").click
  end

  def then_i_see_link_to_trn_guidance
    expect(page).to have_element(:div, text: "If you do not know a teacher’s TRN, you can ask them for it. They can find a lost TRN, or apply for a new one by following the instructions in the TRN guidance (opens in new tab).", class: "govuk-details__text")
    expect(page).to have_link("TRN guidance (opens in new tab)", href: "https://www.gov.uk/guidance/teacher-reference-number-trn")
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def then_i_see_a_validation_error_for_not_entering_any_data
    expect(page).to have_validation_error("Enter a teacher reference number (TRN)")
    expect(page).to have_validation_error("Enter a date of birth")
  end

  def when_i_enter_a_date_of_birth
    within_fieldset("Date of birth") do
      fill_in("Day", with: "21")
      fill_in("Month", with: "1")
      fill_in("Year", with: "1949")
    end
  end

  def then_i_see_a_validation_error_for_not_entering_a_trn
    expect(page).to have_validation_error("Enter a teacher reference number (TRN)")
    expect(page).not_to have_validation_error("Enter a date of birth")
  end

  def when_i_clear_the_date_of_birth
    within_fieldset("Date of birth") do
      fill_in("Day", with: "")
      fill_in("Month", with: "")
      fill_in("Year", with: "")
    end
  end

  def and_i_enter_a_trn
    fill_in "TRN", with: "8888888"
  end

  def then_i_see_a_validation_error_for_not_entering_a_date_of_birth
    expect(page).to have_validation_error("Enter a date of birth")
    expect(page).not_to have_validation_error("Enter a teacher reference number (TRN)")
  end

  def when_i_enter_an_invalid_trn
    fill_in "TRN", with: "2"
  end

  def then_i_see_a_validation_error_for_not_entering_a_valid_trn
    expect(page).to have_validation_error("Enter a 7 digit teacher reference number (TRN)")
  end

  def when_i_enter_valid_data_that_does_not_exist_in_the_teaching_record_service
    fill_in "TRN", with: "8888888"

    within_fieldset("Date of birth") do
      fill_in("Day", with: "14")
      fill_in("Month", with: "9")
      fill_in("Year", with: "1991")
    end
  end

  def then_i_see_the_no_results_page
    expect(page).to have_title("No results found for ‘8888888’ - Mentor not found - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")

    expect(page).to have_element(:span, text: "Mentor not found", class: "govuk-caption-l")
    expect(page).to have_h1("No results found for ‘8888888’")
    expect(page).to have_element(:p, text: "Check that you typed in the teacher reference number (TRN) correctly.", class: "govuk-body")
  end

  def when_i_click_on_change_your_search
    click_on "Change your search"
  end

  def then_i_see_the_find_mentor_form_with_the_trn_and_date_of_birth_prefilled
    expect(page).to have_field("TRN", with: "8888888")

    expect(page).to have_field("Day", with: "14")
    expect(page).to have_field("Month", with: "9")
    expect(page).to have_field("Year", with: "1991")
  end

  def stub_no_results_teaching_record_response
    allow(TeachingRecord::GetTeacher).to receive(:call)
      .with(trn: "8888888", date_of_birth: "1991-09-14")
      .and_raise TeachingRecord::RestClient::TeacherNotFoundError
  end
end
