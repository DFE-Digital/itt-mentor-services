require "rails_helper"

RSpec.describe "Placements school user adds mentors to schools", type: :system, service: :placements do
  let!(:school) { create(:placements_school, name: "School") }
  let(:another_school) { create(:placements_school, name: "Another School") }
  let(:claims_mentor) { create(:claims_mentor) }
  let(:placements_mentor) { create(:placements_mentor) }
  let(:new_mentor) { build(:placements_mentor) }

  before { given_i_sign_in_as_anne }

  scenario "I can navigate back to the index page" do
    given_i_navigate_to_schools_mentors_list
    and_i_click_on("Add mentor")
    when_i_click_on("Back")
    then_i_see_the_index_page(school)
    when_i_click_on("Add mentor")
    and_i_click_on("Cancel")
    then_i_see_the_index_page(school)
  end

  scenario "I can view help with the trn" do
    given_i_navigate_to_schools_mentors_list
    and_i_click_on "Add mentor"
    when_i_click_on_help_text
    then_i_see_link_to_trn_guidance
  end

  scenario "I do not enter a trn" do
    given_i_navigate_to_schools_mentors_list
    and_i_click_on("Add mentor")
    when_i_click_on("Continue")
    then_i_see_the_error("Enter a teacher reference number (TRN)")
  end

  scenario "I enter an invalid trn" do
    given_i_navigate_to_schools_mentors_list
    and_i_click_on("Add mentor")
    when_i_enter_trn("12a")
    and_i_click_on("Continue")
    then_i_see_the_error("Enter a valid teacher reference number (TRN)")
  end

  scenario "I enter a trn of mentor who already exists for this school" do
    given_a_placements_mentor_exists(school, placements_mentor)
    given_i_navigate_to_schools_mentors_list
    and_i_click_on("Add mentor")
    when_i_enter_trn(placements_mentor.trn)
    and_i_click_on("Continue")
    then_i_see_the_error("The mentor has already been added")
  end

  scenario "I enter the trn of an existing claims mentor" do
    given_a_claims_mentor_exists
    given_i_navigate_to_schools_mentors_list
    and_i_click_on("Add mentor")
    when_i_enter_trn(claims_mentor.trn)
    and_i_click_on("Continue")
    then_i_see_check_page_for(claims_mentor)
    when_i_click_on("Back")
    then_i_see_form_with_trn(claims_mentor.trn)
    when_i_click_on("Continue")
    then_i_see_check_page_for(claims_mentor)
    when_i_click_on("Change")
    then_i_see_form_with_trn(claims_mentor.trn)
    when_i_click_on("Continue")
    then_i_see_check_page_for(claims_mentor)
    when_i_click_on("Add mentor")
    then_mentor_is_added(claims_mentor.full_name)
  end

  scenario "I enter the trn of an existing placements mentor from another school" do
    given_a_placements_mentor_exists(another_school, placements_mentor)
    given_i_navigate_to_schools_mentors_list
    and_i_click_on("Add mentor")
    when_i_enter_trn(placements_mentor.trn)
    and_i_click_on("Continue")
    then_i_see_check_page_for(placements_mentor)
    when_i_click_on("Back")
    then_i_see_form_with_trn(placements_mentor.trn)
    when_i_click_on("Continue")
    then_i_see_check_page_for(placements_mentor)
    when_i_click_on("Add mentor")
    then_mentor_is_added(placements_mentor.full_name)
  end

  describe "when trn is valid-looking, but does not exists in Teaching Record Service" do
    before do
      allow(TeachingRecord::GetTeacher).to receive(:call)
                                             .with(trn: new_mentor.trn)
                                             .and_raise TeachingRecord::RestClient::TeacherNotFoundError
    end

    scenario "I enter a a valid-looking trn that does not exist in the Teaching Record service" do
      given_i_navigate_to_schools_mentors_list
      and_i_click_on("Add mentor")
      when_i_enter_trn(new_mentor.trn)
      and_i_click_on("Continue")
      then_i_see_no_results_page(school.name, new_mentor.trn)
      when_i_click_on "Change your search"
      then_i_see_form_with_trn(new_mentor.trn)
    end
  end

  describe "when trn is valid-looking and mentor is found on Teaching Record Service" do
    before do
      allow(TeachingRecord::GetTeacher).to receive(:call)
                                             .with(trn: new_mentor.trn)
                                             .and_return teaching_record_valid_response(new_mentor)
    end

    scenario "I enter a valid-looking trn that does exist on the Teaching Record Service" do
      given_i_navigate_to_schools_mentors_list
      and_i_click_on("Add mentor")
      when_i_enter_trn(new_mentor.trn)
      and_i_click_on("Continue")
      then_i_see_check_page_for(new_mentor)
      when_i_click_on("Add mentor")
      then_mentor_is_added(new_mentor.full_name)
    end
  end

  def given_i_sign_in_as_anne
    user = create(:placements_user, :anne)
    create(:user_membership, user:, organisation: school)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Start now"
  end

  def given_a_claims_mentor_exists
    create(:claims_mentor_membership, school: another_school, mentor: claims_mentor)
  end

  def given_a_placements_mentor_exists(school, mentor)
    create(:placements_mentor_membership, school:, mentor:)
  end

  def given_i_navigate_to_schools_mentors_list
    within(".app-primary-navigation__nav") do
      click_on "Mentors"
    end
  end

  def when_i_click_on(text)
    click_on text
  end

  def when_i_click_on_help_text
    find("span", text: "Help with the teacher reference number (TRN)").click
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
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Mentors", current: "page"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def then_mentor_is_added(mentor_name)
    within(".govuk-notification-banner--success") do
      expect(page).to have_content "Mentor added"
    end
    expect(page).to have_content mentor_name
  end

  def when_i_enter_trn(trn)
    fill_in "placements-mentor-form-trn-field", with: trn
  end

  def then_i_see_the_index_page(school)
    expect(page).to have_current_path placements_school_mentors_path(school), ignore_query: true
  end

  def then_i_see_the_error(message)
    expect(page).to have_title "Error: Enter a teacher reference number (TRN)"
    within(".govuk-error-summary") do
      expect(page).to have_content message
    end

    within(".govuk-form-group--error") do
      expect(page).to have_content message
    end
  end

  def then_i_see_form_with_trn(trn)
    expect(page.find("#placements-mentor-form-trn-field").value).to eq(trn)
  end

  def then_i_see_no_results_page(_school_name, trn)
    expect(page).to have_title "No results found for ‘#{trn}’"
    expect(page).to have_content "Add mentor"
    expect(page).to have_content "No results found for ‘#{trn}’"
  end

  def teaching_record_valid_response(mentor)
    {
      "trn" => mentor.trn.to_s,
      "firstName" => mentor.first_name.to_s,
      "middleName" => "",
      "lastName" => mentor.last_name.to_s,
    }
  end

  def then_i_see_link_to_trn_guidance
    expect(page).to have_content "If you don’t have a TRN, read the Teacher reference number (TRN) guidance (opens in new tab) to find a lost TRN, or apply for one."
    expect(page).to have_link("Teacher reference number (TRN) guidance (opens in new tab)", href: "https://www.gov.uk/guidance/teacher-reference-number-trn")
  end

  alias_method :and_i_click_on, :when_i_click_on
end
