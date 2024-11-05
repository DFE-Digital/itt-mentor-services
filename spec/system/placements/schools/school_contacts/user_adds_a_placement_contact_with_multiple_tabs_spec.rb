require "rails_helper"

RSpec.describe "Adding a placement contact to a school with multiple tabs", service: :placements, type: :system do
  scenario "User adds a placement contact to their school using multiple tabs", :js do
    given_i_am_signed_in

    when_i_view_my_organisation_details_page_in_the_first_tab
    then_i_do_not_see_any_placement_contact_details_in_the_first_tab

    when_i_click_on_add_placement_contact_in_the_first_tab
    and_i_fill_in_the_placement_contact_form_in_the_first_tab
    and_i_submit_the_form_in_the_first_tab
    then_i_see_the_check_your_answers_page_in_the_first_tab

    when_i_view_my_organisation_details_page_in_the_second_tab
    then_i_do_not_see_any_placement_contact_details_in_the_second_tab

    when_i_click_on_add_placement_contact_in_the_second_tab
    and_i_fill_in_the_placement_contact_form_in_the_second_tab
    and_i_submit_the_form_in_the_second_tab
    then_i_see_the_check_your_answers_page_in_the_second_tab

    when_i_refresh_the_first_tab
    then_the_school_placement_details_have_not_changed_in_the_first_tab

    when_i_refresh_the_second_tab
    then_the_school_placement_details_have_not_changed_in_the_second_tab

    when_i_click_on_add_placement_contact_in_the_first_tab
    then_i_see_my_placement_contact_details_in_the_first_tab
    and_i_see_a_success_message_in_the_first_tab

    when_i_click_on_add_placement_contact_in_the_second_tab
    then_i_see_an_error_message_in_the_second_tab
  end

  private

  def given_i_am_signed_in
    @school = build(:placements_school, with_school_contact: false)
    @windows = [open_new_window, open_new_window]
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_view_my_organisation_details_page_in_the_first_tab
    within_window @windows.first do
      visit placements_school_path(@school)
      expect(page).to have_title("Organisation details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Organisation details")
      expect(page).to have_h1(@school.name)
      expect(page).to have_h2("Placement contact")
      expect(page).to have_h2("School")
      expect(page).to have_summary_list_row("Name", @school.name)
      expect(page).to have_summary_list_row("UKPRN", @school.ukprn)
      expect(page).to have_summary_list_row("URN", @school.urn)
    end
  end

  def then_i_do_not_see_any_placement_contact_details_in_the_first_tab
    within_window @windows.first do
      expect(page).not_to have_css "#school-contact-details"
    end
  end

  def when_i_click_on_add_placement_contact_in_the_first_tab
    within_window @windows.first do
      click_on "Add placement contact"
    end
  end

  def and_i_fill_in_the_placement_contact_form_in_the_first_tab
    within_window @windows.first do
      fill_in "First name", with: "First"
      fill_in "Last name", with: "Tab"
      fill_in "Email address", with: "first_tab@example.com"
    end
  end

  def and_i_submit_the_form_in_the_first_tab
    within_window @windows.first do
      click_on "Continue"
    end
  end

  def then_i_see_the_check_your_answers_page_in_the_first_tab
    within_window @windows.first do
      expect(page).to have_title("Check your answers - Organisation details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Organisation details")
      expect(page).to have_h1("Check your answers")
      expect(page).to have_summary_list_row("First name", "First")
      expect(page).to have_summary_list_row("Last name", "Tab")
      expect(page).to have_summary_list_row("Email address", "first_tab@example.com")
    end
  end

  def when_i_view_my_organisation_details_page_in_the_second_tab
    within_window @windows.second do
      visit placements_school_path(@school)
      expect(page).to have_title("Organisation details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Organisation details")
      expect(page).to have_h1(@school.name)
      expect(page).to have_h2("Placement contact")
      expect(page).to have_h2("School")
      expect(page).to have_summary_list_row("Name", @school.name)
      expect(page).to have_summary_list_row("UKPRN", @school.ukprn)
      expect(page).to have_summary_list_row("URN", @school.urn)
    end
  end

  def then_i_do_not_see_any_placement_contact_details_in_the_second_tab
    within_window @windows.second do
      expect(page).not_to have_css "#school-contact-details"
    end
  end

  def when_i_click_on_add_placement_contact_in_the_second_tab
    within_window @windows.second do
      click_on "Add placement contact"
    end
  end

  def and_i_fill_in_the_placement_contact_form_in_the_second_tab
    within_window @windows.second do
      fill_in "First name", with: "Second"
      fill_in "Last name", with: "Tab"
      fill_in "Email address", with: "second_tab@example.com"
    end
  end

  def and_i_submit_the_form_in_the_second_tab
    within_window @windows.second do
      click_on "Continue"
    end
  end

  def then_i_see_the_check_your_answers_page_in_the_second_tab
    within_window @windows.second do
      expect(page).to have_title("Check your answers - Organisation details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Organisation details")
      expect(page).to have_h1("Check your answers")
      expect(page).to have_summary_list_row("First name", "Second")
      expect(page).to have_summary_list_row("Last name", "Tab")
      expect(page).to have_summary_list_row("Email address", "second_tab@example.com")
    end
  end

  def when_i_refresh_the_first_tab
    within_window @windows.first do
      page.refresh
    end
  end

  def then_the_school_placement_details_have_not_changed_in_the_first_tab
    within_window @windows.first do
      expect(page).to have_title("Check your answers - Organisation details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Organisation details")
      expect(page).to have_h1("Check your answers")
      expect(page).to have_summary_list_row("First name", "First")
      expect(page).to have_summary_list_row("Last name", "Tab")
      expect(page).to have_summary_list_row("Email address", "first_tab@example.com")
    end
  end

  def when_i_refresh_the_second_tab
    within_window @windows.second do
      page.refresh
    end
  end

  def then_the_school_placement_details_have_not_changed_in_the_second_tab
    within_window @windows.second do
      expect(page).to have_title("Check your answers - Organisation details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Organisation details")
      expect(page).to have_h1("Check your answers")
      expect(page).to have_summary_list_row("First name", "Second")
      expect(page).to have_summary_list_row("Last name", "Tab")
      expect(page).to have_summary_list_row("Email address", "second_tab@example.com")
    end
  end

  def then_i_see_my_placement_contact_details_in_the_first_tab
    within_window @windows.first do
      expect(page).to have_title("Organisation details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Organisation details")
      expect(page).to have_h1(@school.name)
      expect(page).to have_h2("Placement contact")
      within "#school-contact-details" do
        expect(page).to have_summary_list_row("First name", "First")
        expect(page).to have_summary_list_row("Last name", "Tab")
        expect(page).to have_summary_list_row("Email address", "first_tab@example.com")
      end
    end
  end

  def and_i_see_a_success_message_in_the_first_tab
    within_window @windows.first do
      expect(page).to have_success_banner("Placement contact added")
    end
  end

  def then_i_see_an_error_message_in_the_second_tab
    within_window @windows.second do
      expect(page).to have_important_banner("You cannot perform this action")
    end
  end
end
