require "rails_helper"

RSpec.describe "School user adds a user already onboarded to the school", service: :placements, type: :system do
  scenario do
    given_a_school_exists
    and_a_user_is_onboarded_to_the_school
    and_i_am_signed_in
    when_i_navigate_to_users
    then_i_am_see_the_users_index_page
    and_i_see_the_user_joe_bloggs_listed

    when_i_click_on_add_user
    then_i_see_the_user_details_form

    when_i_enter_the_new_users_details_for_joe_bloggs
    and_i_click_on_continue
    then_i_see_a_validation_error_for_entering_an_existing_email_address
  end

  private

  def given_a_school_exists
    @school = create(:placements_school)
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

  def then_i_see_a_validation_error_for_entering_an_existing_email_address
    expect(page).to have_validation_error("Email address already in use")
  end
end
