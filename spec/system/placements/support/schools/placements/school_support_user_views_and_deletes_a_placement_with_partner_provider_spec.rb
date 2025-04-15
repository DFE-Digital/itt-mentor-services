require "rails_helper"

RSpec.describe "School support user views and deletes a placement with a partner provider", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_organisations_index_page
    and_i_select_springfield_elementary
    then_i_see_the_placements_index_page
    and_i_see_my_placement

    when_i_click_on_my_placement
    then_i_see_the_placement_details_page

    when_i_click_on_the_delete_placement_link
    then_i_see_the_you_cannot_delete_this_placement_page
  end

  private

  def given_that_placements_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")

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
      partner_providers: [@provider],
    )

    @primary_english_subject = build(:subject, name: "Primary with english", subject_area: :primary)

    @autumn_term = build(:placements_term, name: "Autumn term")
    @spring_term = create(:placements_term, name: "Spring term")
    @summer_term = create(:placements_term, name: "Summer term")

    @next_academic_year = Placements::AcademicYear.current.next
    @next_academic_year_name = @next_academic_year.name

    @placement = create(
      :placement,
      school: @springfield_elementary_school,
      subject: @primary_english_subject,
      year_group: :year_1,
      terms: [@autumn_term],
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

  def when_i_am_on_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(page).to have_element(:a, text: "Add placement", class: "govuk-button")
  end

  alias_method :then_i_see_the_placements_index_page, :when_i_am_on_the_placements_index_page

  def and_i_see_my_placement
    expect(page).to have_element(:td, text: "Primary with english (Year 1)", class: "govuk-table__cell")
    expect(page).to have_element(:td, text: "Mentor not assigned", class: "govuk-table__cell")
    expect(page).to have_element(:td, text: "Autumn term", class: "govuk-table__cell")
    expect(page).to have_element(:td, text: "Aes Sedai Trust", class: "govuk-table__cell")
  end

  def when_i_click_on_my_placement
    click_on "Primary with english (Year 1)"
  end

  def then_i_see_the_placement_details_page
    expect(page).to have_title("Primary with english (Year 1) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Unavailable", "orange")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 1")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term")
    expect(page).to have_summary_list_row("Mentor", "Add a mentor")
    expect(page).to have_summary_list_row("Provider", "Aes Sedai Trust")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
    expect(page).to have_link("Delete placement", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}/remove")
  end

  def when_i_click_on_the_delete_placement_link
    click_on "Delete placement"
  end

  def then_i_see_the_you_cannot_delete_this_placement_page
    expect(page).to have_title("You cannot delete this placement - Primary with english (Year 1) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("You cannot delete this placement")
    expect(page).to have_element(:p, text: "Aes Sedai Trust must be removed from the placement before you can delete it.")
    expect(page).to have_element(:a, text: "Back", class: "govuk-back-link")
  end

  def when_i_click_on_the_back_link
    click_on "Back"
  end

  def and_i_click_on_change_provider
    click_on "Change Provider"
  end

  def then_i_see_the_select_a_provider_page
    expect(page).to have_title("Select a provider - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "Select a provider", class: "govuk-fieldset__legend")
    expect(page).to have_element(:span, text: "My provider is not listed", class: "govuk-details__summary-text")
    expect(page).to have_link("Cancel", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}")
  end

  def when_i_select_not_yet_known
    choose "Not yet known"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_placement_details_page_without_a_provider
    expect(page).to have_title("Primary with english (Year 1) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Available", "turquoise")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 1")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term")
    expect(page).to have_summary_list_row("Mentor", "Add a mentor")
    expect(page).to have_summary_list_row("Provider", "Assign a provider")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
    expect(page).to have_link("Delete placement", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}/remove")
  end

  def and_i_click_on_the_delete_placement_button
    click_on "Delete placement"
  end

  def then_i_see_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(page).to have_element(:a, text: "Add placement", class: "govuk-button")
  end

  def and_i_see_a_success_message
    expect(page).to have_success_banner("Placement deleted")
  end

  def and_my_placement_has_been_deleted
    expect(page).not_to have_element(:td, text: "Primary with english (Year 1)", class: "govuk-table__cell")
    expect(page).not_to have_element(:td, text: "Mentor not assigned", class: "govuk-table__cell")
    expect(page).not_to have_element(:td, text: "Autumn term", class: "govuk-table__cell")
    expect(page).not_to have_element(:td, text: "Aes Sedai Trust", class: "govuk-table__cell")
  end
end
