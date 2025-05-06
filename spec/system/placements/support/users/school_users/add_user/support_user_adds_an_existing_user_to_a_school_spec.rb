require "rails_helper"

RSpec.describe "Support user adds an existing user to a school", service: :placements, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_that_schools_exist
    and_a_provider_exists
    and_a_user_exists_for_the_guildford_school_and_a_provider
    and_i_am_signed_in
    when_i_click_on_ashford_school
    and_i_click_users_in_the_primary_navigation
    then_i_see_the_users_index_page_for_ashford_school
    and_i_see_there_are_no_users

    when_i_click_on_add_user
    then_i_see_the_form_to_enter_the_users_details

    when_i_enter_the_users_details
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_back
    then_i_see_the_form_to_enter_the_users_details
    and_i_see_the_form_is_prefilled

    when_i_click_on_back
    then_i_see_the_users_index_page_for_ashford_school

    when_i_click_on_add_user
    then_i_see_the_form_to_enter_the_users_details

    when_i_enter_the_users_details
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_cancel
    then_i_see_the_users_index_page_for_ashford_school

    when_i_click_on_add_user
    then_i_see_the_form_to_enter_the_users_details

    when_i_click_on_cancel
    then_i_see_the_users_index_page_for_ashford_school

    when_i_click_on_add_user
    then_i_see_the_form_to_enter_the_users_details

    when_i_enter_the_users_details
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_confirm_and_add_user
    then_i_see_the_users_index_page_for_ashford_school
    and_i_see_susan_storm_has_been_added_successfully
    and_i_see_user_susan_storm
    and_susan_storm_is_sent_an_email
  end

  private

  def given_that_schools_exist
    @ashford_school = create(
      :placements_school,
      name: "Ashford School",
    )
    @guildford_school = create(
      :placements_school,
      name: "Royal Grammar School Guildford",
    )
  end

  def and_a_provider_exists
    @provider = create(:placements_provider)
  end

  def and_a_user_exists_for_the_guildford_school_and_a_provider
    create(:placements_user,
           first_name: "Susan",
           last_name: "Storm",
           email: "susan_storm@example.com",
           schools: [@guildford_school],
           providers: [@provider])
  end

  def and_i_am_signed_in
    sign_in_placements_support_user
  end

  def when_i_click_on_ashford_school
    click_on "Ashford School"
  end

  def and_i_click_users_in_the_primary_navigation
    within(primary_navigation) do
      click_on "Users"
    end
  end

  def then_i_see_the_users_index_page_for_ashford_school
    expect(page).to have_title("Users - Manage school placements - GOV.UK")
    expect(page).to have_h1("Users")
    expect(page).to have_element(:span, text: "Ashford School")
    expect(page).to have_current_path(placements_school_users_path(@ashford_school))
  end

  def and_i_see_there_are_no_users
    expect(page).to have_element(:p, text: "No users found")
  end

  def when_i_click_on_add_user
    click_on "Add user"
  end

  def then_i_see_the_form_to_enter_the_users_details
    expect(page).to have_title(
      "Personal details - User details - Manage school placements - GOV.UK",
    )
    expect(page).to have_h1("Personal details")
    expect(page).to have_element(:span, text: "User details", class: "govuk-caption-l")
  end

  def when_i_enter_the_users_details
    fill_in "First name", with: "Susan"
    fill_in "Last name", with: "Storm"
    fill_in "Email address", with: "susan_storm@example.com"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title(
      "Confirm user details - Manage school placements - GOV.UK",
    )
    expect(page).to have_h1("Confirm user details", class: "govuk-heading-m")
    expect(page).to have_h2("User", class: "govuk-heading-m")
    expect(page).to have_summary_list_row(
      "First name", "Susan"
    )
    expect(page).to have_summary_list_row(
      "Last name", "Storm"
    )
    expect(page).to have_summary_list_row(
      "Email address", "susan_storm@example.com"
    )
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def and_i_see_the_form_is_prefilled
    expect(page).to have_field("First name", with: "Susan")
    expect(page).to have_field("Last name", with: "Storm")
    expect(page).to have_field("Email address", with: "susan_storm@example.com")
  end

  def when_i_click_on_cancel
    click_on "Cancel"
  end

  def when_i_click_on_confirm_and_add_user
    click_on "Confirm and add user"
  end

  def and_i_see_susan_storm_has_been_added_successfully
    expect(page).to have_success_banner(
      "User added",
      "Susan Storm can now view, edit and create placements at your school.",
    )
  end

  def and_i_see_user_susan_storm
    expect(page).to have_table_row({
      "Name" => "Susan Storm",
      "Email address" => "susan_storm@example.com",
    })
  end

  def and_susan_storm_is_sent_an_email
    email = ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?("susan_storm@example.com") &&
        delivery.subject == "ACTION NEEDED: Sign-in to the Manage school placements service"
    end
    expect(email).not_to be_nil
  end
end
