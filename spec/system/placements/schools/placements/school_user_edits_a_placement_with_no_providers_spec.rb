require "rails_helper"

RSpec.describe "School user edits a placement with no providers", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_my_placement

    when_i_click_on_my_placement
    then_i_see_the_placement_details_page
    and_i_see_the_add_a_provider_link

    when_i_click_on_add_a_provider
    then_i_see_the_providers_index_page

    when_i_click_on_add_provider
    then_i_see_the_add_a_provider_page

    when_i_fill_in_the_providers_name
    and_i_click_on_continue
    then_i_see_the_provider_in_the_search_results

    when_i_choose_aes_sedai_trust
    and_i_click_on_continue
    then_i_see_the_confirm_provider_details_page

    when_i_click_on_confirm_and_add_provider
    then_i_see_the_providers_index_page
    and_i_see_a_success_message

    when_i_click_on_the_placements_navigation_item
    then_i_see_the_placements_index_page

    when_i_click_on_my_placement
    then_i_see_the_placement_details_page_with_assign_a_provider_text
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

    @current_academic_year_name = Placements::AcademicYear.current.name

    @placement = create(
      :placement,
      school: @springfield_elementary_school,
      subject: @primary_english_subject,
      year_group: :year_1,
      terms: [@autumn_term],
    )

    @aes_sedai_provider = create(:placements_provider, name: "Aes Sedai Trust")
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

  def and_i_see_the_add_a_provider_link
    expect(page).to have_link("Add a partner provider", href: "/schools/#{@springfield_elementary_school.id}/partner_providers")
  end

  def when_i_click_on_add_a_provider
    click_on "Add a partner provider"
  end

  def then_i_see_the_providers_index_page
    expect(page).to have_title("Providers you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_h1("Providers you work with")
    expect(page).to have_element(:a, text: "Add provider", class: "govuk-button")
  end

  def when_i_click_on_add_provider
    click_on "Add provider"
  end

  def then_i_see_the_add_a_provider_page
    expect(page).to have_title("Add a provider - Provider details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_element(:label, text: "Add a provider", class: "govuk-label govuk-label--l")
  end

  def when_i_fill_in_the_providers_name
    fill_in "Add a provider", with: "Aes Sedai Trust"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_provider_in_the_search_results
    expect(page).to have_title("1 results found for ‘Aes Sedai Trust’ - Provider details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_element(:legend, text: "1 results found for 'Aes Sedai Trust'", class: "govuk-fieldset__legend govuk-fieldset__legend--l")
  end

  def when_i_choose_aes_sedai_trust
    choose "Aes Sedai Trust"
  end

  def then_i_see_the_confirm_provider_details_page
    expect(page).to have_title("Confirm provider details - Provider details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_h1("Confirm provider details")
    expect(page).to have_summary_list_row("Name", "Aes Sedai Trust")
  end

  def when_i_click_on_confirm_and_add_provider
    click_on "Confirm and add provider"
  end

  def and_i_see_a_success_message
    expect(page).to have_success_banner("Provider added")
  end

  def when_i_click_on_the_placements_navigation_item
    within ".app-primary-navigation__nav" do
      click_on "Placements"
    end
  end

  def then_i_see_the_placement_details_page_with_assign_a_provider_text
    expect(page).to have_title("Primary with english (Year 1) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Available", "turquoise")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 1")
    expect(page).to have_summary_list_row("Academic year", "This year (#{@current_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term")
    expect(page).to have_summary_list_row("Mentor", "Add a mentor")
    expect(page).to have_summary_list_row("Provider", "Assign a provider")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
    expect(page).to have_link("Delete placement", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}/remove")
  end
end
