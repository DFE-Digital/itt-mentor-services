require "rails_helper"

RSpec.describe "School user uses multilple tabs to add mentors", :js, service: :placements, type: :system do
  before do
    stub_valid_teaching_record_response_for_mister_bergstrom
    stub_valid_teaching_record_response_for_otto_mann
  end

  scenario do
    given_mentors_and_schools_exist
    and_i_am_signed_in_using_two_tabs

    when_i_am_on_the_mentors_index_page_in_the_first_tab
    and_i_click_on_add_mentor_in_the_first_tab
    then_i_see_the_tab_one_find_mentor_page

    # the placements mentor is enrolled at another school
    when_i_enter_the_trn_and_date_of_birth_for_an_existing_placements_mentor_at_another_school
    and_i_click_on_continue_in_the_first_tab
    then_i_see_the_tab_one_confirm_mentor_details_page

    when_i_am_on_the_mentors_index_page_in_the_second_tab
    and_i_click_on_add_mentor_in_the_second_tab
    then_i_see_the_tab_two_find_mentor_page

    when_i_enter_the_trn_and_date_of_birth_for_a_new_mentor
    and_i_click_on_continue_in_the_second_tab
    then_i_see_the_tab_two_confirm_mentor_details_page

    when_i_click_on_change_in_the_first_tab
    then_i_see_the_find_mentor_form_with_the_trn_and_date_of_birth_prefilled_for_mister_bergstrom

    when_i_click_on_continue_in_the_first_tab
    then_i_see_the_tab_one_confirm_mentor_details_page

    when_i_click_on_tab_one_confirm_and_add_mentor
    then_i_see_a_success_message_for_mister_bergstrom
    and_i_see_the_mentors_index_page_with_mister_bergstrom_listed

    when_i_click_on_tab_two_confirm_and_add_mentor
    then_i_see_a_success_message_for_otto_mann
    and_i_see_the_mentors_index_page_with_otto_mann_listed
  end

  private

  def given_mentors_and_schools_exist
    @school = build(:school, :placements, name: "Springfield Elementary")
    @shelbyville_elementary = build(:school, :placements, name: "Shelbyville Elementary")
    @shelbyville_mentor = build(:placements_mentor, trn: "1111111", first_name: "Mister", last_name: "Bergstrom")
    create(:placements_mentor_membership, school: @shelbyville_elementary, mentor: @shelbyville_mentor)
    @new_mentor = create(:placements_mentor, trn: "3333333", first_name: "Otto", last_name: "Mann")
  end

  def and_i_am_signed_in_using_two_tabs
    @windows = [open_new_window, open_new_window]
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_am_on_the_mentors_index_page_in_the_first_tab
    within_window @windows.first do
      visit placements_school_mentors_path(@school)
      expect(page).to have_title("Mentors at your school - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Mentors")

      expect(page).to have_h1("Mentors at your school")
      expect(page).to have_element(:p, text: "Add mentors to be able to assign them to your placements.", class: "govuk-body")
      expect(page).to have_link("Add mentor", href: "/schools/#{@school.id}/mentors/new")
    end
  end

  def when_i_am_on_the_mentors_index_page_in_the_second_tab
    within_window @windows.second do
      visit placements_school_mentors_path(@school)
      expect(page).to have_title("Mentors at your school - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Mentors")

      expect(page).to have_h1("Mentors at your school")
      expect(page).to have_element(:p, text: "Add mentors to be able to assign them to your placements.", class: "govuk-body")
      expect(page).to have_link("Add mentor", href: "/schools/#{@school.id}/mentors/new")
    end
  end

  def and_i_click_on_add_mentor_in_the_first_tab
    within_window @windows.first do
      click_on "Add mentor"
    end
  end

  def and_i_click_on_add_mentor_in_the_second_tab
    within_window @windows.second do
      click_on "Add mentor"
    end
  end

  def then_i_see_the_tab_one_find_mentor_page
    within_window @windows.first do
      expect(page).to have_title("Find teacher - Mentor details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Mentors")

      expect(page).to have_element(:span, text: "Mentor details", class: "govuk-caption-l")
      expect(page).to have_h1("Find teacher")
    end
  end

  def then_i_see_the_tab_two_find_mentor_page
    within_window @windows.second do
      expect(page).to have_title("Find teacher - Mentor details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Mentors")

      expect(page).to have_element(:span, text: "Mentor details", class: "govuk-caption-l")
      expect(page).to have_h1("Find teacher")
    end
  end

  def when_i_enter_the_trn_and_date_of_birth_for_an_existing_placements_mentor_at_another_school
    within_window @windows.first do
      fill_in "TRN", with: "1111111"

      within_fieldset("Date of birth") do
        fill_in("Day", with: "7")
        fill_in("Month", with: "2")
        fill_in("Year", with: "1949")
      end
    end
  end

  def when_i_enter_the_trn_and_date_of_birth_for_a_new_mentor
    within_window @windows.second do
      fill_in "TRN", with: "3333333"

      within_fieldset("Date of birth") do
        fill_in("Day", with: "09")
        fill_in("Month", with: "06")
        fill_in("Year", with: "1963")
      end
    end
  end

  def and_i_click_on_continue_in_the_first_tab
    within_window @windows.first do
      click_on "Continue"
    end
  end
  alias_method :when_i_click_on_continue_in_the_first_tab, :and_i_click_on_continue_in_the_first_tab

  def and_i_click_on_continue_in_the_second_tab
    within_window @windows.second do
      click_on "Continue"
    end
  end

  def then_i_see_the_tab_one_confirm_mentor_details_page
    within_window @windows.first do
      expect(page).to have_title("Confirm mentor details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Mentors")

      expect(page).to have_h1("Confirm mentor details")
    end
  end

  def then_i_see_the_tab_two_confirm_mentor_details_page
    within_window @windows.second do
      expect(page).to have_title("Confirm mentor details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Mentors")

      expect(page).to have_h1("Confirm mentor details")
    end
  end

  def when_i_click_on_change_in_the_first_tab
    within_window @windows.first do
      first(:link, "Change").click
    end
  end

  def then_i_see_the_find_mentor_form_with_the_trn_and_date_of_birth_prefilled_for_mister_bergstrom
    within_window @windows.first do
      expect(page).to have_field("TRN", with: "1111111")

      expect(page).to have_field("Day", with: "7")
      expect(page).to have_field("Month", with: "2")
      expect(page).to have_field("Year", with: "1949")
    end
  end

  def when_i_click_on_tab_one_confirm_and_add_mentor
    within_window @windows.first do
      click_on "Confirm and add mentor"
    end
  end

  def when_i_click_on_tab_two_confirm_and_add_mentor
    within_window @windows.second do
      click_on "Confirm and add mentor"
    end
  end

  def then_i_see_a_success_message_for_mister_bergstrom
    within_window @windows.first do
      expect(page).to have_success_banner("Mentor added", "You can now assign Mister Bergstrom to placements.")
    end
  end

  def then_i_see_a_success_message_for_otto_mann
    within_window @windows.second do
      expect(page).to have_success_banner("Mentor added", "You can now assign Otto Mann to placements.")
    end
  end

  def and_i_see_the_mentors_index_page_with_mister_bergstrom_listed
    within_window @windows.first do
      expect(page).to have_table_row({
        "Name" => "Mister Bergstrom",
        "Teacher reference number (TRN)" => "1111111",
      })
    end
  end

  def and_i_see_the_mentors_index_page_with_otto_mann_listed
    within_window @windows.second do
      expect(page).to have_table_row({
        "Name" => "Otto Mann",
        "Teacher reference number (TRN)" => "3333333",
      })
    end
  end

  def stub_valid_teaching_record_response_for_mister_bergstrom
    allow(TeachingRecord::GetTeacher).to receive(:call)
      .with(trn: "1111111", date_of_birth: "1949-02-07")
      .and_return(teaching_record_valid_response_for_mister_bergstrom)
  end

  def teaching_record_valid_response_for_mister_bergstrom
    {
      "trn" => "1111111",
      "firstName" => "Mister",
      "middleName" => "",
      "lastName" => "Bergstrom",
      "dateOfBirth" => "1949-02-07",
    }
  end

  def stub_valid_teaching_record_response_for_otto_mann
    allow(TeachingRecord::GetTeacher).to receive(:call)
      .with(trn: "3333333", date_of_birth: "1963-06-09")
      .and_return(teaching_record_valid_response_for_otto_mann)
  end

  def teaching_record_valid_response_for_otto_mann
    {
      "trn" => "3333333",
      "firstName" => "Otto",
      "middleName" => "",
      "lastName" => "Mann",
      "dateOfBirth" => "1963-06-09",
    }
  end
end
