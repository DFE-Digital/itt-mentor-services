require "rails_helper"

RSpec.describe "School user adds a new user", :js, service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_a_school_exists
    and_i_am_signed_in_using_two_tabs

    when_i_navigate_to_users_index_page_in_the_first_tab
    and_i_click_on_add_user_in_the_first_tab
    then_i_see_the_user_details_form_in_the_first_tab

    when_i_navigate_to_users_index_page_in_the_second_tab
    and_i_click_on_add_user_in_the_second_tab
    then_i_see_the_user_details_form_in_the_second_tab

    when_i_enter_the_new_users_details_for_joe_bloggs_in_the_first_tab
    and_i_click_on_continue_in_the_first_tab
    then_i_see_the_check_your_answers_page_in_the_first_tab
    and_i_see_the_details_i_entered_for_joe_bloggs_in_the_first_tab

    when_i_enter_the_new_users_details_for_sarah_doe_in_the_second_tab
    and_i_click_on_continue_in_the_second_tab
    then_i_see_the_check_your_answers_page_in_the_second_tab
    and_i_see_the_details_i_entered_for_sarah_doe_in_the_second_tab

    when_i_refresh_the_first_tab
    then_i_see_the_check_your_answers_page_in_the_first_tab
    and_i_see_the_details_i_entered_for_joe_bloggs_in_the_first_tab

    when_i_refresh_the_second_tab
    then_i_see_the_check_your_answers_page_in_the_second_tab
    and_i_see_the_details_i_entered_for_sarah_doe_in_the_second_tab

    when_i_click_on_confirm_and_add_user_in_the_first_tab
    then_i_see_the_user_has_been_successfully_added_in_the_first_tab
    and_i_see_the_user_joe_bloggs_listed_in_the_first_tab

    when_i_click_on_confirm_and_add_user_in_the_second_tab
    then_i_see_the_user_has_been_successfully_added_in_the_second_tab
    and_i_see_the_user_sarah_doe_listed_in_the_second_tab
  end

  private

  def given_a_school_exists
    @school = create(:placements_school)
  end

  def and_i_am_signed_in_using_two_tabs
    @windows = [open_new_window, open_new_window]
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_navigate_to_users_index_page_in_the_first_tab
    within_window @windows.first do
      visit placements_school_users_path(@school)

      expect(page).to have_title("Users - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Users")
      expect(page).to have_h1("Users")
      expect(page).to have_paragraph(
        "Users are other members of staff at your school. Adding a user will allow them to view, edit and create placements.",
      )
      expect(page).to have_link("Add user", class: "govuk-button")
    end
  end

  def and_i_click_on_add_user_in_the_first_tab
    within_window @windows.first do
      click_on "Add user"
    end
  end

  def then_i_see_the_user_details_form_in_the_first_tab
    within_window @windows.first do
      expect(page).to have_title("Personal details - User details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Users")
      expect(page).to have_link("Back", href: placements_school_users_path(@school))
      expect(page).to have_span_caption("User details")
      expect(page).to have_h1("Personal details")

      expect(page).to have_field("First name", type: :text)
      expect(page).to have_field("Last name", type: :text)
      expect(page).to have_field("Email address", type: :text)
      expect(page).to have_button("Continue", class: "govuk-button")
      expect(page).to have_link("Cancel", href: placements_school_users_path(@school))
    end
  end

  def when_i_navigate_to_users_index_page_in_the_second_tab
    within_window @windows.second do
      visit placements_school_users_path(@school)

      within(primary_navigation) do
        click_on "Users"
      end

      expect(page).to have_title("Users - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Users")
      expect(page).to have_h1("Users")
      expect(page).to have_paragraph(
        "Users are other members of staff at your school. Adding a user will allow them to view, edit and create placements.",
      )
      expect(page).to have_link("Add user", class: "govuk-button")
    end
  end

  def and_i_click_on_add_user_in_the_second_tab
    within_window @windows.second do
      click_on "Add user"
    end
  end

  def then_i_see_the_user_details_form_in_the_second_tab
    within_window @windows.second do
      expect(page).to have_title("Personal details - User details - Manage school placements - GOV.UK")
      expect(primary_navigation).to have_current_item("Users")
      expect(page).to have_link("Back", href: placements_school_users_path(@school))
      expect(page).to have_span_caption("User details")
      expect(page).to have_h1("Personal details")

      expect(page).to have_field("First name", type: :text)
      expect(page).to have_field("Last name", type: :text)
      expect(page).to have_field("Email address", type: :text)
      expect(page).to have_button("Continue", class: "govuk-button")
      expect(page).to have_link("Cancel", href: placements_school_users_path(@school))
    end
  end

  def when_i_enter_the_new_users_details_for_joe_bloggs_in_the_first_tab
    within_window @windows.first do
      fill_in "First name", with: "Joe"
      fill_in "Last name", with: "Bloggs"
      fill_in "Email address", with: "joe_bloggs@example.com"
    end
  end

  def and_i_click_on_continue_in_the_first_tab
    within_window @windows.first do
      click_on "Continue"
    end
  end

  def then_i_see_the_check_your_answers_page_in_the_first_tab
    within_window @windows.first do
      expect(page).to have_title(
        "Confirm user details - Manage school placements - GOV.UK",
      )
      expect(primary_navigation).to have_current_item("Users")
      expect(page).to have_h1("Confirm user details")
      expect(page).to have_paragraph(
        "Once added, they will be able to view, edit and create placements at your school.",
      )
      expect(page).to have_paragraph(
        "We will send them an email with information on how to access the Manage school placements service.",
      )
      expect(page).to have_h2("User")
      expect(page).to have_button("Confirm and add user", class: "govuk-button")
      expect(page).to have_link("Cancel", href: placements_school_users_path(@school))
    end
  end

  def and_i_see_the_details_i_entered_for_joe_bloggs_in_the_first_tab
    within_window @windows.first do
      expect(page).to have_summary_list_row("First name", "Joe")
      expect(page).to have_summary_list_row("Last name", "Bloggs")
      expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
    end
  end

  def when_i_enter_the_new_users_details_for_sarah_doe_in_the_second_tab
    within_window @windows.second do
      fill_in "First name", with: "Sarah"
      fill_in "Last name", with: "Doe"
      fill_in "Email address", with: "sarah_doe@example.com"
    end
  end

  def and_i_click_on_continue_in_the_second_tab
    within_window @windows.second do
      click_on "Continue"
    end
  end

  def then_i_see_the_check_your_answers_page_in_the_second_tab
    within_window @windows.second do
      expect(page).to have_title(
        "Confirm user details - Manage school placements - GOV.UK",
      )
      expect(primary_navigation).to have_current_item("Users")
      expect(page).to have_h1("Confirm user details")
      expect(page).to have_paragraph(
        "Once added, they will be able to view, edit and create placements at your school.",
      )
      expect(page).to have_paragraph(
        "We will send them an email with information on how to access the Manage school placements service.",
      )
      expect(page).to have_h2("User")
      expect(page).to have_button("Confirm and add user", class: "govuk-button")
      expect(page).to have_link("Cancel", href: placements_school_users_path(@school))
    end
  end

  def and_i_see_the_details_i_entered_for_sarah_doe_in_the_second_tab
    within_window @windows.second do
      expect(page).to have_summary_list_row("First name", "Sarah")
      expect(page).to have_summary_list_row("Last name", "Doe")
      expect(page).to have_summary_list_row("Email address", "sarah_doe@example.com")
    end
  end

  def when_i_click_on_confirm_and_add_user_in_the_first_tab
    within_window @windows.first do
      click_on "Confirm and add user"
    end
  end

  def then_i_see_the_user_has_been_successfully_added_in_the_first_tab
    within_window @windows.first do
      expect(page).to have_success_banner("User added")
    end
  end

  def and_i_see_the_user_joe_bloggs_listed_in_the_first_tab
    within_window @windows.first do
      expect(page).to have_table_row({
        "Name" => "Joe Bloggs",
        "Email address" => "joe_bloggs@example.com",
      })
    end
  end

  def when_i_click_on_confirm_and_add_user_in_the_second_tab
    within_window @windows.second do
      click_on "Confirm and add user"
    end
  end

  def then_i_see_the_user_has_been_successfully_added_in_the_second_tab
    within_window @windows.second do
      expect(page).to have_success_banner("User added")
    end
  end

  def and_i_see_the_user_sarah_doe_listed_in_the_second_tab
    within_window @windows.second do
      expect(page).to have_table_row({
        "Name" => "Sarah Doe",
        "Email address" => "sarah_doe@example.com",
      })
    end
  end

  def when_i_refresh_the_first_tab
    within_window @windows.first do
      visit current_path
    end
  end

  def when_i_refresh_the_second_tab
    within_window @windows.second do
      visit current_path
    end
  end
end
