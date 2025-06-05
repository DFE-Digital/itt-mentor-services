require "rails_helper"

RSpec.describe "School user assigns a provider to the school's last available placement",
               :js,
               service: :placements,
               type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_my_placement

    when_i_click_on_my_placement
    then_i_see_the_placement_details_page

    when_i_click_on_assign_a_provider
    and_i_enter_aes_sedai_trust
    then_i_see_a_dropdown_item_for_aes_sedai_trust

    when_i_click_on_the_aes_sedai_trust_dropdown_item
    and_i_click_on_continue
    then_i_see_the_assigning_the_last_placement_page

    when_i_click_on_assign_provider
    then_i_see_the_placement_details_page_with_aes_sedai_trust
    and_i_see_a_provider_updated_success_message
  end

  private

  def given_that_placements_exist
    @aes_sedai_provider = build(:placements_provider, name: "Aes Sedai Trust", code: "111", postcode: "BR11RP")
    @ashaman_provider = build(:placements_provider, name: "Ashaman Trust")

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
      partner_providers: [@aes_sedai_provider, @ashaman_provider],
    )

    @primary_subject = build(:subject, name: "Primary", subject_area: :primary)

    @autumn_term = build(:placements_term, name: "Autumn term")
    @spring_term = create(:placements_term, name: "Spring term")
    @summer_term = create(:placements_term, name: "Summer term")

    @mentor_john_smith = create(:placements_mentor, first_name: "John", last_name: "Smith", schools: [@springfield_elementary_school])
    @mentor_jane_doe = create(:placements_mentor, first_name: "Jane", last_name: "Doe", schools: [@springfield_elementary_school])

    @next_academic_year = Placements::AcademicYear.current.next
    @next_academic_year_name = @next_academic_year.name

    @placement = create(
      :placement,
      school: @springfield_elementary_school,
      subject: @primary_subject,
      year_group: :year_1,
      academic_year: @next_academic_year,
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
  end

  alias_method :then_i_see_the_placements_index_page, :when_i_am_on_the_placements_index_page

  def then_i_see_my_placement
    expect(page).to have_table_row({
      "Placement" => "Primary (Year 1)",
      "Mentor" => "Mentor not assigned",
      "Expected date" => "Autumn term",
      "Provider" => "Provider not assigned",
    })
  end

  def when_i_click_on_my_placement
    click_on "Primary (Year 1)"
  end

  def then_i_see_the_placement_details_page
    expect(page).to have_title("Primary (Year 1) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Available", "green")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 1")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term")
    expect(page).to have_summary_list_row("Mentor", "Select a mentor")
    expect(page).to have_summary_list_row("Provider", "Assign a provider")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
    expect(page).to have_link("Delete placement", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}/remove")
  end

  def when_i_click_on_assign_a_provider
    click_on "Assign a provider"
  end

  def then_i_see_the_select_a_provider_page
    expect(page).to have_title("Select a provider - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:label, text: "Select a provider", class: "govuk-label--l")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}")
  end

  def and_i_enter_aes_sedai_trust
    fill_in "Select a provider", with: "Aes Sedai Trust"
  end

  def then_i_see_a_dropdown_item_for_aes_sedai_trust
    expect(page).to have_css(".autocomplete__option", text: "Aes Sedai Trust (BR11RP, 111)", wait: 10)
  end

  def when_i_click_on_the_aes_sedai_trust_dropdown_item
    page.find(".autocomplete__option", text: "Aes Sedai Trust").click
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_assigning_the_last_placement_page
    expect(page).to have_title(
      "You are assigning your last available placement to a provider - Placement details - Manage school placements - GOV.UK",
    )
    expect(page).to have_span_caption("Placement details")
    expect(page).to have_h1("You are assigning your last available placement to a provider")
    expect(page).to have_paragraph(
      "Your status will be set to ‘no placements available’. Providers will no longer contact you about available placements.",
    )
    expect(page).to have_paragraph("You can add more placements at anytime.")
    expect(page).to have_button("Assign provider", class: "govuk-button")
    expect(page).to have_link(
      "Cancel",
      href: placements_school_placement_path(@springfield_elementary_school, @placement),
    )
  end

  def when_i_click_on_assign_provider
    click_on "Assign provider"
  end

  def then_i_see_the_placement_details_page_with_aes_sedai_trust
    expect(page).to have_title("Primary (Year 1) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Assigned to provider", "blue")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 1")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term")
    expect(page).to have_summary_list_row("Mentor", "Select a mentor")
    expect(page).to have_summary_list_row("Provider", "Aes Sedai Trust")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
  end

  def and_i_see_a_provider_updated_success_message
    expect(page).to have_success_banner("Provider updated")
  end
end
