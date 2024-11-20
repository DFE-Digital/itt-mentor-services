require "rails_helper"

RSpec.describe "School user edits a placement with no mentors", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_my_placement

    when_i_click_on_my_placement
    then_i_see_the_placement_details_page
    and_i_see_the_add_a_mentor_link

    when_i_click_on_add_a_mentor
    then_i_see_the_mentors_index_page

    when_i_click_on_add_mentor
    then_i_see_the_find_teacher_page

    when_i_fill_in_the_details
    and_i_click_on_continue
    then_i_see_the_confirm_details_page

    when_i_click_on_confirm_and_add_mentor
    then_i_see_the_mentors_index_page
    and_i_see_a_success_message

    when_i_click_on_the_placements_navigation_item
    then_i_see_the_placements_index_page

    when_i_click_on_my_placement
    then_i_see_the_placement_details_page_with_assign_a_mentor_text
  end

  private

  def given_that_placements_exist
    @springfield_elementary_school = build(
      :placements_school,
      name: "Springfield Elementary",
      address1: "Westgate Street",
      address2: "Hackney",
      postcode: "E8 3RL",
      group: "Local authority maintained schools",
      phase: "Primary",
      gender: "Mixed",
      minimum_age: 3,
      maximum_age: 11,
      religious_character: "Does not apply",
      admissions_policy: "Not applicable",
      urban_or_rural: "(England/Wales) Urban major conurbation",
      percentage_free_school_meals: 15,
      rating: "Outstanding",
    )

    @primary_english_subject = build(:subject, name: "Primary with english", subject_area: :primary)

    @autumn_term = build(:placements_term, name: "Autumn term")
    @spring_term = create(:placements_term, name: "Spring term")
    @summer_term = create(:placements_term, name: "Summer term")

    @current_academic_year_name = Placements::AcademicYear.current.name

    @placement = create(
      :placement,
      school: @springfield_elementary_school,
      subject: @primary_english_subject,
      year_group: :year_1,
      terms: [@autumn_term],
    )

    stub_valid_teaching_record_response
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@springfield_elementary_school])
  end

  def when_i_am_on_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(page).to have_element(:a, text: "Add placement", class: "govuk-button")
    expect(secondary_navigation).to have_current_item("This year (#{@current_academic_year_name})")
  end

  alias_method :then_i_see_the_placements_index_page, :when_i_am_on_the_placements_index_page

  def then_i_see_my_placement
    expect(page).to have_element(:td, text: "Primary with english (Year 1)", class: "govuk-table__cell")
    expect(page).to have_element(:td, text: "Not yet known", class: "govuk-table__cell")
    expect(page).to have_element(:td, text: "Autumn term", class: "govuk-table__cell")
    expect(page).to have_element(:td, text: "Not yet known", class: "govuk-table__cell")
  end

  def when_i_click_on_my_placement
    click_on "Primary with english (Year 1)"
  end

  def then_i_see_the_placement_details_page
    expect(page).to have_title("Primary with english (Year 1) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Available", "turquoise")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 1")
    expect(page).to have_summary_list_row("Academic year", "This year (#{@current_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term")
    expect(page).to have_summary_list_row("Mentor", "Add a mentor")
    expect(page).to have_summary_list_row("Provider", "Add a partner provider")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
    expect(page).to have_link("Delete placement", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}/remove")
  end

  def and_i_see_the_add_a_mentor_link
    expect(page).to have_link("Add a mentor", href: "/schools/#{@springfield_elementary_school.id}/mentors")
  end

  def when_i_click_on_add_a_mentor
    click_on "Add a mentor"
  end

  def then_i_see_the_mentors_index_page
    expect(page).to have_title("Mentors at your school - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("Mentors at your school")
    expect(page).to have_element(:a, text: "Add mentor", class: "govuk-button")
  end

  def when_i_click_on_add_mentor
    click_on "Add mentor"
  end

  def then_i_see_the_find_teacher_page
    expect(page).to have_title("Find teacher - Mentor details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("Find teacher")
  end

  def when_i_fill_in_the_details
    fill_in "Teacher reference number (TRN)", with: "1234565"
    fill_in "Day", with: "09"
    fill_in "Month", with: "01"
    fill_in "Year", with: "1991"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_confirm_details_page
    expect(page).to have_title("Confirm mentor details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("Confirm mentor details")
    expect(page).to have_summary_list_row("Teacher reference number (TRN)", "1234565")
    expect(page).to have_summary_list_row("Date of birth", "09/01/1991")
  end

  def when_i_click_on_confirm_and_add_mentor
    click_on "Confirm and add mentor"
  end

  def and_i_see_a_success_message
    expect(page).to have_success_banner("Mentor added")
  end

  def when_i_click_on_the_placements_navigation_item
    within ".app-primary-navigation__nav" do
      click_on "Placements"
    end
  end

  def then_i_see_the_placement_details_page_with_assign_a_mentor_text
    expect(page).to have_title("Primary with english (Year 1) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Available", "turquoise")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 1")
    expect(page).to have_summary_list_row("Academic year", "This year (#{@current_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term")
    expect(page).to have_summary_list_row("Mentor", "Select a mentor")
    expect(page).to have_summary_list_row("Provider", "Add a partner provider")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
    expect(page).to have_link("Delete placement", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}/remove")
  end

  def teaching_record_response
    {
      "trn" => "1234565",
      "firstName" => "John",
      "middleName" => "",
      "lastName" => "Doe",
      "dateOfBirth" => "1991-01-09",
    }
  end

  def stub_valid_teaching_record_response
    allow(TeachingRecord::GetTeacher).to receive(:call)
      .with(trn: "1234565", date_of_birth: "1991-01-09")
      .and_return teaching_record_response
  end
end
