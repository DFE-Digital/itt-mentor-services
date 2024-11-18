require "rails_helper"

RSpec.describe "Primary school user edits a placement", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_my_placement

    when_i_click_on_my_placement
    then_i_see_the_placement_details_page
    and_i_see_the_add_a_mentor_link
    and_i_see_the_add_a_partner_provider_link
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
    # TODO: create tag matcher
    expect(page).to have_element(:strong, text: "Available", class: "govuk-tag govuk-tag--turquoise")
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

  def and_i_see_the_add_a_partner_provider_link
    expect(page).to have_link("Add a partner provider", href: "/schools/#{@springfield_elementary_school.id}/partner_providers")
  end
end
