require "rails_helper"

RSpec.describe "Claims support user adds mentors to schools", type: :system, service: :claims do
  let!(:school) { create(:claims_school, name: "School") }
  let(:another_school) { create(:claims_school, name: "Another School") }
  let(:claims_mentor) { create(:claims_mentor) }
  let(:another_claims_mentor) { create(:claims_mentor) }
  let(:new_mentor) { build(:claims_mentor) }

  before { given_i_sign_in_as_colin }

  scenario "I can navigate back to the index page" do
    given_i_navigate_to_schools_mentors_list(school)
    and_i_click_on("Add mentor")
    when_i_click_on("Back")
    then_i_see_the_index_page(school)
    when_i_click_on("Add mentor")
    and_i_click_on("Cancel")
    then_i_see_the_index_page(school)
  end

  scenario "I do not enter a trn" do
    given_i_navigate_to_schools_mentors_list(school)
    and_i_click_on("Add mentor")
    when_i_click_on("Continue")
    then_i_see_errors(["Enter a teacher reference number (TRN)", "Enter a date of birth"])
  end

  scenario "I enter an invalid trn" do
    given_i_navigate_to_schools_mentors_list(school)
    and_i_click_on("Add mentor")
    when_i_enter_trn("12a")
    and_i_click_on("Continue")
    then_i_see_errors(["Enter a 7 digit teacher reference number (TRN)"])
  end

  describe "Use trn of an existing claim mentor within a school" do
    before do
      allow(TeachingRecord::GetTeacher).to receive(:call)
        .with(trn: another_claims_mentor.trn, date_of_birth: "1986-11-12")
        .and_return teaching_record_valid_response(another_claims_mentor, "1986-11-12")
    end

    scenario "I enter a trn of mentor who already exists for this school" do
      given_a_another_claims_mentor_exists(school, another_claims_mentor)
      given_i_navigate_to_schools_mentors_list(school)
      and_i_click_on("Add mentor")
      when_i_enter_trn(another_claims_mentor.trn)
      when_i_enter_date_of_birth(12, 11, 1986)
      and_i_click_on("Continue")
      then_i_see_errors(["The mentor has already been added"])
    end
  end

  describe "Use trn of an existing claim mentor" do
    before do
      allow(TeachingRecord::GetTeacher).to receive(:call)
       .with(trn: claims_mentor.trn, date_of_birth: "1986-11-12")
       .and_return teaching_record_valid_response(new_mentor, "1986-11-12")
    end

    scenario "I enter the trn of an existing claims mentor" do
      given_a_claims_mentor_exists
      given_i_navigate_to_schools_mentors_list(school)
      and_i_click_on("Add mentor")
      when_i_enter_trn(claims_mentor.trn)
      when_i_enter_date_of_birth(12, 11, 1986)
      and_i_click_on("Continue")
      then_i_see_check_page_for(new_mentor)
      when_i_click_on("Back")
      then_i_see_form_with_trn(claims_mentor.trn)
      then_i_see_form_with_dob("12", "11", "1986")
      when_i_click_on("Continue")
      then_i_see_check_page_for(new_mentor)
      when_i_click_on("Change")
      then_i_see_form_with_trn(claims_mentor.trn)
      then_i_see_form_with_dob("12", "11", "1986")
      when_i_click_on("Continue")
      then_i_see_check_page_for(new_mentor)
      when_i_click_on("Save mentor")
      then_mentor_is_added(claims_mentor.full_name)
    end
  end

  describe "Use trn of an existing claim mentor with wrong date of birth" do
    before do
      allow(TeachingRecord::GetTeacher).to receive(:call)
       .with(trn: claims_mentor.trn, date_of_birth: "1999-11-12")
       .and_raise TeachingRecord::RestClient::TeacherNotFoundError
    end

    scenario "I enter the trn of an existing claims mentor" do
      given_a_claims_mentor_exists
      given_i_navigate_to_schools_mentors_list(school)
      and_i_click_on("Add mentor")
      when_i_enter_trn(claims_mentor.trn)
      when_i_enter_date_of_birth(12, 11, 1999)
      and_i_click_on("Continue")
      then_i_see_no_results_page(school.name, claims_mentor.trn)
    end
  end

  describe "Use trn of an existing placements mentor from another school" do
    before do
      allow(TeachingRecord::GetTeacher).to receive(:call)
       .with(trn: another_claims_mentor.trn, date_of_birth: "1987-09-14")
       .and_return teaching_record_valid_response(another_claims_mentor, "1987-9-14")
    end

    scenario "I enter the trn of an existing claims mentor from another school" do
      given_a_another_claims_mentor_exists(another_school, another_claims_mentor)
      given_i_navigate_to_schools_mentors_list(school)
      and_i_click_on("Add mentor")
      when_i_enter_trn(another_claims_mentor.trn)
      when_i_enter_date_of_birth(14, 9, 1987)
      and_i_click_on("Continue")
      then_i_see_check_page_for(another_claims_mentor)
      when_i_click_on("Back")
      then_i_see_form_with_trn(another_claims_mentor.trn)
      then_i_see_form_with_dob("14", "9", "1987")
      when_i_click_on("Continue")
      then_i_see_check_page_for(another_claims_mentor)
      when_i_click_on("Save mentor")
      then_mentor_is_added(another_claims_mentor.full_name)
    end
  end

  describe "when trn is valid-looking, but does not exists in Teaching Record Service" do
    before do
      allow(TeachingRecord::GetTeacher).to receive(:call)
                                             .with(trn: new_mentor.trn, date_of_birth: "1986-11-12")
                                             .and_raise TeachingRecord::RestClient::TeacherNotFoundError
    end

    scenario "I enter a a valid-looking trn that does not exist in the Teaching Record service" do
      given_i_navigate_to_schools_mentors_list(school)
      and_i_click_on("Add mentor")
      when_i_enter_trn(new_mentor.trn)
      when_i_enter_date_of_birth(12, 11, 1986)
      and_i_click_on("Continue")
      then_i_see_no_results_page(school.name, new_mentor.trn)
      when_i_click_on "Change your search"
      then_i_see_form_with_trn(new_mentor.trn)
      then_i_see_form_with_dob("12", "11", "1986")
    end
  end

  describe "when trn is valid-looking and mentor is found on Teaching Record Service" do
    before do
      allow(TeachingRecord::GetTeacher).to receive(:call)
                                             .with(trn: new_mentor.trn, date_of_birth: "1986-11-12")
                                             .and_return teaching_record_valid_response(new_mentor, "1986-11-12")
    end

    scenario "I enter a valid-looking trn that does exist on the Teaching Record Service" do
      given_i_navigate_to_schools_mentors_list(school)
      and_i_click_on("Add mentor")
      when_i_enter_trn(new_mentor.trn)
      when_i_enter_date_of_birth(12, 11, 1986)
      and_i_click_on("Continue")
      then_i_see_check_page_for(new_mentor)
      when_i_click_on("Save mentor")
      then_mentor_is_added(new_mentor.full_name)
    end
  end

  describe "when trn is valid-looking and mentor is found on Teaching Record Service but dob is wrong" do
    before do
      allow(TeachingRecord::GetTeacher).to receive(:call)
                                             .with(trn: new_mentor.trn, date_of_birth: "1999-11-12")
                                             .and_raise TeachingRecord::RestClient::TeacherNotFoundError
    end

    scenario "I enter a valid-looking trn that does exist on the Teaching Record Service with wrong dob" do
      given_i_navigate_to_schools_mentors_list(school)
      and_i_click_on("Add mentor")
      when_i_enter_trn(new_mentor.trn)
      when_i_enter_date_of_birth(12, 11, 1999)
      and_i_click_on("Continue")
      then_i_see_no_results_page(school.name, new_mentor.trn)
      when_i_click_on "Change your search"
      then_i_see_form_with_trn(new_mentor.trn)
      then_i_see_form_with_dob("12", "11", "1999")
    end
  end

  def given_i_sign_in_as_colin
    user = create(:claims_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_a_claims_mentor_exists
    create(:claims_mentor_membership, school: another_school, mentor: claims_mentor)
  end

  def given_a_another_claims_mentor_exists(school, mentor)
    create(:claims_mentor_membership, school:, mentor:)
  end

  def given_i_navigate_to_schools_mentors_list(school)
    click_on school.name
    within(".app-secondary-navigation") do
      click_on "Mentors"
    end
  end

  def when_i_click_on(text)
    click_on(text, match: :first)
  end

  def when_i_click_on_help_text
    find(
      "span",
      text: "If you do not have the teacher reference number (TRN)",
    ).click
  end

  def then_i_see_check_page_for(mentor)
    expect_organisations_to_be_selected_in_primary_navigation
    expect(page).to have_content "Add mentor"
    expect(page).to have_content "Check your answers"
    name_row = page.all(".govuk-summary-list__row")[0]
    within(name_row) do
      expect(page).to have_content "First name"
      expect(page).to have_content mentor.first_name
    end
  end

  def expect_organisations_to_be_selected_in_primary_navigation
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisations", current: "page"
      expect(page).to have_link "Support users", current: "false"
    end
  end

  def then_mentor_is_added(mentor_name)
    within(".govuk-notification-banner--success") do
      expect(page).to have_content "Mentor added"
    end
    expect(page).to have_content mentor_name
  end

  def when_i_enter_trn(trn)
    fill_in "claims-mentor-form-trn-field", with: trn
  end

  def when_i_enter_date_of_birth(day, month, year)
    within_fieldset("Date of birth") do
      fill_in("Day", with: day)
      fill_in("Month", with: month)
      fill_in("Year", with: year)
    end
  end

  def then_i_see_the_index_page(school)
    expect(page).to have_current_path claims_support_school_mentors_path(school), ignore_query: true
  end

  def then_i_see_errors(errors)
    expect(page).to have_title "Error: Enter a teacher reference number (TRN)"
    within(".govuk-error-summary") do
      expect(page).to have_content errors.join("")
    end

    errors.each_with_index do |error, index|
      within("div.govuk-form-group--error:nth(#{index + 1})") do
        expect(page).to have_content error
      end
    end
  end

  def then_i_see_form_with_trn(trn)
    expect(page.find("#claims-mentor-form-trn-field").value).to eq(trn)
  end

  def then_i_see_form_with_dob(day, month, year)
    expect(page.find("#claims_mentor_form_date_of_birth_1i").value).to eq(year)
    expect(page.find("#claims_mentor_form_date_of_birth_2i").value).to eq(month)
    expect(page.find("#claims_mentor_form_date_of_birth_3i").value).to eq(day)
  end

  def then_i_see_no_results_page(_school_name, trn)
    expect(page).to have_title "No results found for ‘#{trn}’"
    expect(page).to have_content "Add mentor - #{school.name}"
    expect(page).to have_content "No results found for ‘#{trn}’"
  end

  def teaching_record_valid_response(mentor, date_of_birth)
    {
      "trn" => mentor.trn.to_s,
      "firstName" => mentor.first_name.to_s,
      "middleName" => "",
      "lastName" => mentor.last_name.to_s,
      "dateOfBirth" => date_of_birth,
    }
  end

  def then_i_see_link_to_trn_guidance
    expect(page).to have_content "If your mentor does not have a TRN, share the teacher reference number (TRN) guidance (opens in new tab) to find a lost TRN, or apply for one."
    expect(page).to have_link("teacher reference number (TRN) guidance (opens in new tab)", href: "https://www.gov.uk/guidance/teacher-reference-number-trn")
  end

  alias_method :and_i_click_on, :when_i_click_on
end
