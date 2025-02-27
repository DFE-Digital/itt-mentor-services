require "rails_helper"

RSpec.describe "School user selects no and completes the interested journey",
               service: :placements,
               type: :system do
  scenario do
    given_the_bulk_add_placements_flag_is_enabled
    and_academic_years_exist
    and_i_am_signed_in
    when_i_am_on_the_placements_index_page
    and_i_click_on_bulk_add_placements
    then_i_see_the_appetite_form

    when_i_select_interested_in_hosting_placements
    and_i_click_on_continue
    then_i_see_the_help_available_to_you_page

    when_i_click_on_continue
    then_i_see_the_are_you_interested_in_listing_placements_form

    when_i_select_no
    and_i_click_on_continue

    when_i_click_on_continue
    then_i_see_the_school_contact_form

    when_i_fill_in_the_school_contact_details
    and_i_click_on_continue
    then_i_see_my_responses_with_successfully_updated
    and_the_schools_contact_has_been_updated
    and_the_schools_hosting_interest_for_the_next_year_is_updated
  end

  private

  def given_the_bulk_add_placements_flag_is_enabled
    Flipper.add(:bulk_add_placements)
    Flipper.enable(:bulk_add_placements)
  end

  def and_academic_years_exist
    current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = current_academic_year.name
    @next_academic_year = current_academic_year.next
    @next_academic_year_name = @next_academic_year.name
  end

  def and_i_am_signed_in
    @school = create(:placements_school, with_school_contact: false)
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_am_on_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(secondary_navigation).to have_current_item("This year (#{@current_academic_year_name}")
    expect(page).to have_link("Bulk add placements")
  end

  alias_method :then_i_am_on_the_placements_index_page,
               :when_i_am_on_the_placements_index_page

  def when_i_click_on_bulk_add_placements
    click_on "Bulk add placements"
  end

  alias_method :and_i_click_on_bulk_add_placements,
               :when_i_click_on_bulk_add_placements

  def then_i_see_the_appetite_form
    expect(page).to have_title(
      "What is your appetite for ITT the coming academic year (#{@next_academic_year_name})? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "What is your appetite for ITT the coming academic year (#{@next_academic_year_name})?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Actively looking to host placements", type: :radio)
    expect(page).to have_field("Interested in hosting placements", type: :radio)
    expect(page).to have_field("Not open to hosting placements", type: :radio)
    expect(page).to have_field("Placements already organised with providers", type: :radio)
  end

  def when_i_select_interested_in_hosting_placements
    choose "Interested in hosting placements"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end

  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_help_available_to_you_page
    expect(page).to have_title(
      "Help available to you - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Help available to you")
  end

  def then_i_see_the_are_you_interested_in_listing_placements_form
    expect(page).to have_title(
      "Would you like to list some placements to be seen by providers? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :h1,
      text: "Would you like to list some placements to be seen by providers?",
      class: "govuk-fieldset__heading",
    )
  end

  def when_i_select_no
    choose "No"
  end

  def then_i_see_the_school_contact_form
    expect(page).to have_title(
      "Who is your contact for ITT? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Who is your contact for ITT?")

    expect(page).to have_field("First name")
    expect(page).to have_field("Last name")
    expect(page).to have_field("Email address")
  end

  def when_i_fill_in_the_school_contact_details
    fill_in "First name", with: "Joe"
    fill_in "Last name", with: "Bloggs"
    fill_in "Email address", with: "joe_bloggs@example.com"
  end

  def then_i_see_my_responses_with_successfully_updated
    expect(page).to have_success_banner("Thank you for providing your responses")
  end

  def and_the_schools_contact_has_been_updated
    school_contact = @school.school_contact
    expect(school_contact.first_name).to eq("Joe")
    expect(school_contact.last_name).to eq("Bloggs")
    expect(school_contact.email_address).to eq("joe_bloggs@example.com")
  end

  def and_the_schools_hosting_interest_for_the_next_year_is_updated
    hosting_interest = @school.hosting_interests.for_academic_year(@next_academic_year).last
    expect(hosting_interest.appetite).to eq("interested")
  end
end
