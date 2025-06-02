require "rails_helper"

RSpec.describe "Provider user adds a new user", service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_a_provider_exists
    and_i_am_signed_in
    when_i_navigate_to_users
    then_i_am_see_the_users_index_page
    and_the_only_user_listed_is_myself

    when_i_click_on_add_user
    then_i_see_the_user_details_form

    when_i_do_not_enter_any_user_details
    and_i_click_on_continue
    then_i_see_a_validation_error_for_not_entering_a_first_name
    and_i_see_a_validation_error_for_not_entering_a_last_name
    and_i_see_a_validation_error_for_not_entering_an_email_address

    when_i_enter_invalid_user_details
    and_i_click_on_continue
    then_i_see_a_validation_error_entering_an_invalid_email_address

    when_i_enter_the_new_users_details_for_joe_bloggs
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page
    and_i_see_the_details_i_entered_for_joe_bloggs

    when_i_click_on_back
    then_i_see_the_user_details_form
    and_the_form_is_populated_with_user_details_for_joe_bloggs

    when_i_enter_the_new_users_details_for_sarah_doe
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page
    and_i_see_the_details_i_entered_for_sarah_doe

    when_i_click_on_confirm_and_add_user
    then_i_am_see_the_users_index_page
    and_i_see_the_user_has_been_successfully_added
    and_i_see_the_user_sarah_doe_listed
    and_sarah_doe_is_sent_an_invite_notification_email
  end

  private

  def given_a_provider_exists
    @provider = create(:placements_provider)
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def when_i_navigate_to_users
    within(primary_navigation) do
      click_on "Users"
    end
  end

  def then_i_am_see_the_users_index_page
    expect(page).to have_title("Users - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Users")
    expect(page).to have_paragraph(
      "Users are other members of staff at your organisation. Adding a user will allow them to access placement information.",
    )
    expect(page).to have_link("Add user", class: "govuk-button")
  end

  def and_the_only_user_listed_is_myself
    expect(page.all(".govuk-table__row").count).to eq(2) # includes header row
    expect(page).to have_table_row({
      "Name" => @current_user.full_name,
      "Email address" => @current_user.email,
    })
  end

  def when_i_click_on_add_user
    click_on "Add user"
  end

  def then_i_see_the_user_details_form
    expect(page).to have_title("Personal details - User details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_link("Back", href: placements_provider_users_path(@provider))
    expect(page).to have_span_caption("User details")
    expect(page).to have_h1("Personal details")

    expect(page).to have_field("First name", type: :text)
    expect(page).to have_field("Last name", type: :text)
    expect(page).to have_field("Email address", type: :text)
    expect(page).to have_button("Continue", class: "govuk-button")
    expect(page).to have_link("Cancel", href: placements_provider_users_path(@provider))
  end

  def when_i_do_not_enter_any_user_details; end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_a_validation_error_for_not_entering_a_first_name
    expect(page).to have_validation_error("Enter a first name")
  end

  def and_i_see_a_validation_error_for_not_entering_a_last_name
    expect(page).to have_validation_error("Enter a last name")
  end

  def and_i_see_a_validation_error_for_not_entering_an_email_address
    expect(page).to have_validation_error("Enter an email address")
  end

  def when_i_enter_invalid_user_details
    fill_in "First name", with: "Joe"
    fill_in "Last name", with: "Bloggs"
    fill_in "Email address", with: "invalid_email"
  end

  def then_i_see_a_validation_error_entering_an_invalid_email_address
    expect(page).to have_validation_error(
      "Enter an email address in the correct format, like name@example.com",
    )
  end

  def when_i_enter_the_new_users_details_for_joe_bloggs
    fill_in "First name", with: "Joe"
    fill_in "Last name", with: "Bloggs"
    fill_in "Email address", with: "joe_bloggs@example.com"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title(
      "Confirm user details - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Confirm user details")
    expect(page).to have_paragraph(
      "We will send them an email with information on how to access the Manage school placements service.",
    )
    expect(page).to have_h2("User")
    expect(page).to have_button("Confirm and add user", class: "govuk-button")
    expect(page).to have_link("Cancel", href: placements_provider_users_path(@provider))
  end

  def and_i_see_the_details_i_entered_for_joe_bloggs
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def and_the_form_is_populated_with_user_details_for_joe_bloggs
    expect(page).to have_field("First name", type: :text, with: "Joe")
    expect(page).to have_field("Last name", type: :text, with: "Bloggs")
    expect(page).to have_field("Email address", type: :text, with: "joe_bloggs@example.com")
  end

  def when_i_enter_the_new_users_details_for_sarah_doe
    fill_in "First name", with: "Sarah"
    fill_in "Last name", with: "Doe"
    fill_in "Email address", with: "sarah_doe@example.com"
  end

  def and_i_see_the_details_i_entered_for_sarah_doe
    expect(page).to have_summary_list_row("First name", "Sarah")
    expect(page).to have_summary_list_row("Last name", "Doe")
    expect(page).to have_summary_list_row("Email address", "sarah_doe@example.com")
  end

  def when_i_click_on_confirm_and_add_user
    click_on "Confirm and add user"
  end

  def and_i_see_the_user_has_been_successfully_added
    expect(page).to have_success_banner("User added")
  end

  def and_i_see_the_user_sarah_doe_listed
    expect(page).to have_table_row({
      "Name" => "Sarah Doe",
      "Email address" => "sarah_doe@example.com",
    })
  end

  def and_sarah_doe_is_sent_an_invite_notification_email
    invite_email = ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?("sarah_doe@example.com") &&
        delivery.subject == "Invitation to join Manage school placements"
    end

    expect(invite_email).not_to be_nil
  end
end
