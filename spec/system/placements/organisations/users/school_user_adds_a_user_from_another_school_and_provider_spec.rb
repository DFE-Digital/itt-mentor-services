require "rails_helper"

RSpec.describe "School user adds a user from another school and provider", service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_a_provider_exists
    and_two_schools_exists
    and_a_user_has_been_onboarded_to_the_school_and_provider
    and_i_am_signed_in
    when_i_navigate_to_users
    then_i_am_see_the_users_index_page
    and_the_only_user_listed_is_myself

    when_i_click_on_add_user
    then_i_see_the_user_details_form

    when_i_enter_the_new_users_details_for_joe_bloggs
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page
    and_i_see_the_details_i_entered_for_joe_bloggs

    when_i_click_on_confirm_and_add_user
    then_i_am_see_the_users_index_page
    and_i_see_the_user_has_been_successfully_added
    and_i_see_the_user_joe_bloggs_listed
    and_joe_bloggs_is_sent_an_invite_notification_email
  end

  private

  def given_a_provider_exists
    @provider = create(:placements_provider, name: "The Camden Provider")
  end

  def and_two_schools_exists
    @school = create(:placements_school, name: "The London School")
    @another_school = create(:placements_school, name: "The Brixton School")
  end

  def and_a_user_has_been_onboarded_to_the_school_and_provider
    @onboarded_user = create(
      :placements_user,
      first_name: "Joe",
      last_name: "Bloggs",
      email: "joe_bloggs@example.com",
      schools: [@another_school],
      providers: [@provider],
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
    expect(page).to have_link("Back", href: placements_school_users_path(@school))
    expect(page).to have_span_caption("User details")
    expect(page).to have_h1("Personal details")

    expect(page).to have_field("First name", type: :text)
    expect(page).to have_field("Last name", type: :text)
    expect(page).to have_field("Email address", type: :text)
    expect(page).to have_button("Continue", class: "govuk-button")
    expect(page).to have_link("Cancel", href: placements_school_users_path(@school))
  end

  def when_i_enter_the_new_users_details_for_joe_bloggs
    fill_in "First name", with: "Joe"
    fill_in "Last name", with: "Bloggs"
    fill_in "Email address", with: "joe_bloggs@example.com"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page
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

  def and_i_see_the_details_i_entered_for_joe_bloggs
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
  end

  def when_i_click_on_confirm_and_add_user
    click_on "Confirm and add user"
  end

  def and_i_see_the_user_has_been_successfully_added
    expect(page).to have_success_banner("User added")
  end

  def and_i_see_the_user_joe_bloggs_listed
    expect(page).to have_table_row({
      "Name" => "Joe Bloggs",
      "Email address" => "joe_bloggs@example.com",
    })
  end

  def and_joe_bloggs_is_sent_an_invite_notification_email
    invite_email = ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?("joe_bloggs@example.com") &&
        delivery.subject == "ACTION NEEDED: Sign-in to the Manage school placements service"
    end

    expect(invite_email).not_to be_nil
  end
end
