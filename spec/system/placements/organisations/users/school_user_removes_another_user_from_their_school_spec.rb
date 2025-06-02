require "rails_helper"

RSpec.describe "School user removes another user from their school", service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_a_school_exists
    and_a_user_is_onboarded_to_the_school
    and_i_am_signed_in
    when_i_navigate_to_users
    then_i_am_see_the_users_index_page
    and_i_see_the_user_joe_bloggs_listed

    when_i_click_on_joe_bloggs
    then_i_see_the_user_details_page_for_joe_bloggs

    when_i_click_on_delete_user
    then_i_see_the_are_you_sure_page

    when_i_click_on_delete_user
    then_i_am_see_the_users_index_page
    and_i_see_the_user_has_been_successfully_deleted
    and_i_do_not_see_the_user_joe_bloggs_listed
    and_joe_bloggs_is_sent_a_removal_notification_email
  end

  private

  def given_a_school_exists
    @school = create(:placements_school, name: "The London School")
  end

  def and_a_user_is_onboarded_to_the_school
    @user = create(
      :placements_user,
      first_name: "Joe",
      last_name: "Bloggs",
      email: "joe_bloggs@example.com",
      schools: [@school],
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
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
      "Users are other members of staff at your school. Adding a user will allow them to view, edit and create placements.",
    )
    expect(page).to have_link("Add user", class: "govuk-button")
  end

  def and_i_see_the_user_joe_bloggs_listed
    expect(page).to have_table_row({
      "Name" => "Joe Bloggs",
      "Email address" => "joe_bloggs@example.com",
    })
  end

  def when_i_click_on_joe_bloggs
    click_on "Joe Bloggs"
  end

  def then_i_see_the_user_details_page_for_joe_bloggs
    expect(page).to have_title("Joe Bloggs - Manage school placements - GOV.UK")
    expect(page).to have_h1("Joe Bloggs")
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
    expect(page).to have_link("Delete user", class: "app-link--destructive")
  end

  def when_i_click_on_delete_user
    click_on "Delete user"
  end

  def then_i_see_the_are_you_sure_page
    expect(page).to have_title(
      "Are you sure you want to delete this user? - Joe Bloggs - Manage school placements - GOV.UK",
    )
    expect(page).to have_span_caption("Joe Bloggs")
    expect(page).to have_h1("Are you sure you want to delete this user?")
    expect(page).to have_paragraph(
      "Joe Bloggs will no longer be able to view, create or manage placements at your school.",
    )
    expect(page).to have_warning_text(
      "The user will be sent an email to tell them you deleted them from The London School.",
    )
    expect(page).to have_button("Delete user", class: "govuk-button--warning")
    expect(page).to have_link("Cancel", href: placements_school_user_path(@school, @user))
  end

  def and_i_see_the_user_has_been_successfully_deleted
    expect(page).to have_success_banner("User deleted")
  end

  def and_i_do_not_see_the_user_joe_bloggs_listed
    expect(page).not_to have_table_row({
      "Name" => "Joe Bloggs",
    })
  end

  def and_joe_bloggs_is_sent_a_removal_notification_email
    invite_email = ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?("joe_bloggs@example.com") &&
        delivery.subject == "You have been removed from Manage school placements"
    end

    expect(invite_email).not_to be_nil
  end
end
