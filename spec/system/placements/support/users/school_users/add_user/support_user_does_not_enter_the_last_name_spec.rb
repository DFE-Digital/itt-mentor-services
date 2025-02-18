require "rails_helper"

RSpec.describe "Support user does not enter the last name", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in
    when_i_click_on_ashford_school
    and_i_click_users_in_the_primary_navigation
    then_i_see_the_users_index_page_for_ashford_school
    and_i_see_there_are_no_users

    when_i_click_on_add_user
    then_i_see_the_form_to_enter_the_users_details

    when_i_enter_the_users_first_name_and_email_address
    and_i_click_on_continue
    then_i_see_an_error_related_to_the_users_last_name
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

  def when_i_enter_the_users_first_name_and_email_address
    fill_in "First name", with: "Susan"
    fill_in "Email address", with: "susan_storm@example.com"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_an_error_related_to_the_users_last_name
    expect(page).to have_validation_error(
      "Enter a last name",
    )
  end
end
