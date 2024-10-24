require "rails_helper"

RSpec.describe "Placements school user adds mentors to schools", service: :placements, type: :system do
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

  scenario "I do not enter anything" do
    given_i_navigate_to_schools_mentors_list
    and_i_click_on("Add mentor")
    when_i_click_on("Continue")
    then_i_see_the_error("Enter a teacher reference number (TRN)")
  end

  scenario "I do not enter a trn" do
    given_i_navigate_to_schools_mentors_list
    and_i_click_on("Add mentor")
    when_i_enter_date_of_birth(1, 1, 1990)
    when_i_click_on("Continue")
    then_i_see_the_error("Enter a teacher reference number (TRN)")
    and_i_do_not_see_the_error("Enter a date of birth")
  end

  scenario "I do not enter a date of birth" do
    given_i_navigate_to_schools_mentors_list
    and_i_click_on("Add mentor")
    when_i_enter_trn(1_212_121)
    and_i_click_on("Continue")
    then_i_see_the_error("Enter a date of birth")
    and_i_do_not_see_the_error("Enter a teacher reference number (TRN)")
  end

  scenario "I enter an invalid trn" do
    given_i_navigate_to_schools_mentors_list
    and_i_click_on("Add mentor")
    when_i_enter_trn("12a")
    and_i_click_on("Continue")
    then_i_see_the_error("Enter a 7 digit teacher reference number (TRN)")
  end

  scenario "I enter a trn of mentor who already exists for this school" do
    stub_valid_teaching_record_response(trn: placements_mentor.trn,
                                        date_of_birth: Struct.new(:day, :month, :year).new(nil, nil, nil).to_s,
                                        mentor: placements_mentor)

    given_a_placements_mentor_exists(school, placements_mentor)
    given_i_navigate_to_schools_mentors_list
    and_i_click_on("Add mentor")
    when_i_enter_trn(placements_mentor.trn)
    and_i_click_on("Continue")
    then_i_see_the_error("The mentor has already been added")
  end

  context "when the mentor already exists in the claims service" do
    before do
      stub_valid_teaching_record_response(trn: claims_mentor.trn,
                                          date_of_birth: "1990-01-01",
                                          mentor: claims_mentor)
    end

    scenario "I enter the trn of an existing claims mentor" do
      given_a_claims_mentor_exists
      given_i_navigate_to_schools_mentors_list
      and_i_click_on("Add mentor")
      when_i_enter_trn(claims_mentor.trn)
      when_i_enter_date_of_birth(1, 1, 1990)
      and_i_click_on("Continue")
      then_i_see_check_page_for(claims_mentor)
      when_i_click_on("Back")
      then_i_see_form_with_trn_and_date_of_birth(claims_mentor.trn, 1, 1, 1990)
      when_i_click_on("Continue")
      then_i_see_check_page_for(claims_mentor)
      when_i_click_on("Change")
      then_i_see_form_with_trn_and_date_of_birth(claims_mentor.trn, 1, 1, 1990)
      when_i_click_on("Continue")
      then_i_see_check_page_for(claims_mentor)
      when_i_click_on("Confirm and add mentor")
      then_mentor_is_added(claims_mentor.full_name)
    end
  end

  context "when the mentor already exists in the placements service" do
    before do
      stub_valid_teaching_record_response(trn: placements_mentor.trn,
                                          date_of_birth: "1990-01-01",
                                          mentor: placements_mentor)
    end

    scenario "I enter the trn of an existing placements mentor from another school" do
      given_a_placements_mentor_exists(another_school, placements_mentor)
      given_i_navigate_to_schools_mentors_list
      and_i_click_on("Add mentor")
      when_i_enter_trn(placements_mentor.trn)
      when_i_enter_date_of_birth(1, 1, 1990)
      and_i_click_on("Continue")
      then_i_see_check_page_for(placements_mentor)
      when_i_click_on("Back")
      then_i_see_form_with_trn_and_date_of_birth(placements_mentor.trn, 1, 1, 1990)
      when_i_click_on("Continue")
      then_i_see_check_page_for(placements_mentor)
      when_i_click_on("Confirm and add mentor")
      then_mentor_is_added(placements_mentor.full_name)
    end
  end

  describe "when trn and date of birth are valid-looking, but does not exists in Teaching Record Service" do
    before do
      allow(TeachingRecord::GetTeacher).to receive(:call)
                                             .with(trn: new_mentor.trn, date_of_birth: "1990-01-01")
                                             .and_raise TeachingRecord::RestClient::TeacherNotFoundError
    end

    scenario "I enter a a valid-looking trn that does not exist in the Teaching Record service" do
      given_i_navigate_to_schools_mentors_list
      and_i_click_on("Add mentor")
      when_i_enter_trn(new_mentor.trn)
      when_i_enter_date_of_birth(1, 1, 1990)
      and_i_click_on("Continue")
      then_i_see_no_results_page(school.name, new_mentor.trn)
      when_i_click_on "Change your search"
      then_i_see_form_with_trn_and_date_of_birth(new_mentor.trn, 1, 1, 1990)
    end
  end

  describe "when trn is valid-looking and mentor is found on Teaching Record Service" do
    before do
      stub_valid_teaching_record_response(trn: new_mentor.trn,
                                          date_of_birth: "1990-01-01",
                                          mentor: new_mentor)
    end

    scenario "I enter a valid-looking trn that does exist on the Teaching Record Service" do
      given_i_navigate_to_schools_mentors_list
      and_i_click_on("Add mentor")
      when_i_enter_trn(new_mentor.trn)
      when_i_enter_date_of_birth(1, 1, 1990)
      and_i_click_on("Continue")
      then_i_see_check_page_for(new_mentor)
      when_i_click_on("Confirm and add mentor")
      then_mentor_is_added(new_mentor.full_name)
    end
  end

  describe "when I use multiple tabs to add mentors", :js do
    let(:elizabeth) { build(:placements_mentor, first_name: "Elizabeth", last_name: "Daly") }
    let(:barbara) { build(:placements_mentor, first_name: "Barbara", last_name: "Dolphin") }

    let(:windows) do
      {
        open_new_window => { mentor: elizabeth, trn: "1234555", date_of_birth: %w[01 01 1990] },
        open_new_window => { mentor: barbara, trn: "1234546", date_of_birth: %w[08 11 1990] },
      }
    end

    before do
      windows.each_value do |details|
        stub_valid_teaching_record_response(trn: details[:trn],
                                            date_of_birth: details[:date_of_birth].reverse.join("-"),
                                            mentor: details[:mentor])
      end
    end

    it "persists the mentor details for each tab upon refresh" do
      windows.each do |window, details|
        within_window window do
          visit placements_school_placements_path(school)
          given_i_navigate_to_schools_mentors_list
          and_i_click_on("Add mentor")
          when_i_enter_trn(details[:trn])
          when_i_enter_date_of_birth(*details[:date_of_birth])
          and_i_click_on("Continue")
          then_i_see_check_page_for(details[:mentor], date_of_birth: details[:date_of_birth].join("/"))
        end
      end

      # We need this test to be A -> B -> A -> B, so we can't combine the loops.
      # rubocop:disable Style/CombinableLoops
      windows.each do |window, details|
        within_window window do
          when_i_refresh_the_page
          then_the_mentor_details_have_not_changed(details[:mentor], date_of_birth: details[:date_of_birth].join("/"))
          when_i_click_on("Confirm and add mentor")
          then_mentor_is_added(details[:mentor].full_name)
        end
      end
      # rubocop:enable Style/CombinableLoops

      given_i_navigate_to_schools_mentors_list
      then_i_see_my_mentors(windows.values)
    end
  end

  private

  def given_i_sign_in_as_anne
    user = create(:placements_user, :anne)
    create(:user_membership, user:, organisation: school)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
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
    click_on text, match: :first
  end

  def when_i_click_on_help_text
    find("span", text: "Help with the TRN").click
  end

  def then_i_see_check_page_for(mentor, date_of_birth: "01/01/1990")
    expect_organisations_to_be_selected_in_primary_navigation
    expect(page).to have_content "Confirm and add mentor"
    expect(page).to have_content "Confirm mentor details"
    name_row = page.all(".govuk-summary-list__row")[0]
    within(name_row) do
      expect(page).to have_content "First name"
      expect(page).to have_content mentor.first_name
    end
    date_of_birth_row = page.all(".govuk-summary-list__row")[3]
    within(date_of_birth_row) do
      expect(page).to have_content "Date of birth"
      expect(page).to have_content date_of_birth
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
    fill_in "TRN", with: trn
  end

  def when_i_enter_date_of_birth(day, month, year)
    within_fieldset("Date of birth") do
      fill_in("Day", with: day)
      fill_in("Month", with: month)
      fill_in("Year", with: year)
    end
  end

  def then_i_see_the_index_page(school)
    expect(page).to have_current_path placements_school_mentors_path(school), ignore_query: true
  end

  def then_i_see_the_error(message, field_index = 0)
    expect(page).to have_title "Error: #{message}"
    within(".govuk-error-summary") do
      expect(page).to have_content message
    end

    within all(".govuk-form-group--error")[field_index] do
      expect(page).to have_content message
    end
  end

  def and_i_do_not_see_the_error(message)
    within(".govuk-error-summary") do
      expect(page).not_to have_content message
    end
  end

  def then_i_see_form_with_trn_and_date_of_birth(trn, day, month, year)
    find_field "TRN", with: trn
    find_field "Day", with: day
    find_field "Month", with: month
    find_field "Year", with: year
  end

  def then_i_see_no_results_page(_school_name, trn)
    expect(page).to have_title "No results found for ‘#{trn}’"
    expect(page).to have_content "Mentor not found"
    expect(page).to have_content "No results found for ‘#{trn}’"
  end

  def teaching_record_valid_response(mentor)
    {
      "trn" => mentor.trn.to_s,
      "firstName" => mentor.first_name.to_s,
      "middleName" => "",
      "lastName" => mentor.last_name.to_s,
      "dateOfBirth" => "1990-01-01",
    }
  end

  def then_i_see_link_to_trn_guidance
    expect(page).to have_content(
      "If you do not know a teacher’s TRN, you can ask them for it. " \
      "They can find a lost TRN, or apply for a new one by following the instructions in the ",
    )
    expect(page).to have_link("TRN guidance (opens in new tab)", href: "https://www.gov.uk/guidance/teacher-reference-number-trn")
  end

  def stub_valid_teaching_record_response(trn:, date_of_birth:, mentor:)
    allow(TeachingRecord::GetTeacher).to receive(:call)
      .with(trn:, date_of_birth:)
      .and_return teaching_record_valid_response(mentor)
  end

  def when_i_refresh_the_page
    visit current_path
  end

  def then_i_see_my_mentors(mentor_details)
    mentor_details.each do |mentor|
      expect(page).to have_content mentor[:mentor].first_name
      expect(page).to have_content mentor[:mentor].last_name
      expect(page).to have_content mentor[:trn]
    end
  end

  alias_method :and_i_click_on, :when_i_click_on
  alias_method :then_the_mentor_details_have_not_changed, :then_i_see_check_page_for
end
