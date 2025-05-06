require "rails_helper"

RSpec.describe "Support user views a placement with a provider", service: :placements, type: :system do
  scenario do
    given_a_placement_exists
    and_i_am_signed_in

    when_i_am_on_the_organisations_index_page
    and_i_select_springfield_elementary
    then_i_see_the_placements_index_page
    and_i_see_the_placement_for_primary_with_english

    when_i_click_primary_with_english
    then_i_see_the_details_of_the_placement_with_a_provider
  end

  private

  def given_a_placement_exists
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

    @mentor_john_smith = create(:placements_mentor, first_name: "John", last_name: "Smith", schools: [@springfield_elementary_school])
    @mentor_jane_doe = create(:placements_mentor, first_name: "Jane", last_name: "Doe", schools: [@springfield_elementary_school])

    @provider = create(:placements_provider, :best_practice_network)

    @next_academic_year = Placements::AcademicYear.current.next
    @next_academic_year_name = @next_academic_year.name

    @placement = create(
      :placement,
      school: @springfield_elementary_school,
      subject: @primary_english_subject,
      year_group: :year_1,
      academic_year: @next_academic_year,
      provider: @provider,
    )
  end

  def and_i_am_signed_in
    sign_in_placements_support_user
  end

  def when_i_am_on_the_organisations_index_page
    expect(page).to have_title("Organisations (2) - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations (2)")
  end

  def and_i_select_springfield_elementary
    click_on "Springfield Elementary"
  end

  def then_i_see_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Springfield Elementary", class: "govuk-heading-s govuk-!-margin-bottom-0")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
  end

  def and_i_see_the_placement_for_primary_with_english
    expect(page).to have_table_row({
      "Subject" => "Primary with english (Year 1)",
      "Mentor" => "Mentor not assigned",
      "Expected date" => "Date not added",
      "Provider" => "Best Practice Network",
    })
  end

  def when_i_click_primary_with_english
    click_on "Primary with english (Year 1)"
  end

  def then_i_see_the_details_of_the_placement_with_a_provider
    expect(page).to have_h1("Primary with english (Year 1)")
    expect(page).to have_summary_list_row("Subject", "Primary with english")
    expect(page).to have_summary_list_row("Year group", "Year 1")
    expect(page).to have_link("Change Year group")
    expect(page).to have_summary_list_row(
      "Academic year",
      "Next year (#{@next_academic_year_name})",
    )
    expect(page).to have_summary_list_row("Expected date", "Any time in the academic year")
    expect(page).to have_link("Change Expected date")
    expect(page).to have_summary_list_row("Mentor", "Select a mentor")
    expect(page).to have_summary_list_row("Provider", "Best Practice Network")
    expect(page).to have_link("Unassign provider")
  end
end
