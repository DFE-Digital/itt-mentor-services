require "rails_helper"

RSpec.describe "School user views and deletes a placement", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_my_placement

    when_i_click_on_my_placement
    then_i_see_the_placement_details_page

    when_i_click_on_the_delete_placement_link
    then_i_see_the_delete_placement_page

    when_i_click_on_the_cancel_link
    then_i_see_the_placement_details_page

    when_i_click_on_the_delete_placement_link
    and_i_click_on_the_delete_placement_button
    then_i_see_the_expression_of_interest_page
    and_i_see_a_success_message
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

    @next_academic_year = Placements::AcademicYear.current.next
    @next_academic_year_name = @next_academic_year.name

    @placement = create(
      :placement,
      school: @springfield_elementary_school,
      subject: @primary_english_subject,
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
    expect(page).to have_link("Add placement", class: "govuk-button")
  end

  alias_method :then_i_see_the_placements_index_page, :when_i_am_on_the_placements_index_page

  def then_i_see_my_placement
    expect(page).to have_table_row({ "Placement": "Primary with english (Year 1)",
                                     "Mentor": "Mentor not assigned",
                                     "Expected date": "Autumn term",
                                     "Provider": "Provider not assigned" })
  end

  def when_i_click_on_my_placement
    click_on "Primary with english (Year 1)"
  end

  def then_i_see_the_placement_details_page
    expect(page).to have_title("Primary with english (Year 1) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Available", "green")
    expect(page).to have_summary_list_row("Subject", "Primary")
    expect(page).to have_summary_list_row("Year group", "Year 1")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term")
    expect(page).to have_summary_list_row("Mentor", "Add a mentor")
    expect(page).to have_summary_list_row("Provider", "Assign a provider")
    expect(page).to have_inset_text("You can preview this placement as it appears to providers.")
    expect(page).to have_link("Delete placement", href: "/schools/#{@springfield_elementary_school.id}/placements/#{@placement.id}/remove")
  end

  def when_i_click_on_the_delete_placement_link
    click_on "Delete placement"
  end

  def then_i_see_the_delete_placement_page
    expect(page).to have_title("Are you sure you want to delete this placement? - Primary with english (Year 1) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Are you sure you want to delete this placement?")
    expect(page).to have_paragraph("It is your responsibility to make sure that anyone relevant to organising this placement is aware it is being deleted.")
    expect(page).to have_link("Cancel")
    expect(page).to have_button("Delete placement")
  end

  def when_i_click_on_the_cancel_link
    click_on "Cancel"
  end

  def and_i_click_on_the_delete_placement_button
    click_on "Delete placement"
  end

  def then_i_see_the_expression_of_interest_page
    expect(page).to have_title(
      "Can your school offer placements for trainee teachers in the academic year #{@next_academic_year_name}? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "Can your school offer placements for trainee teachers in the academic year #{@next_academic_year_name}?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Yes - I can offer placements", type: :radio)
    expect(page).to have_field("Maybe - I’m not sure yet", type: :radio)
    expect(page).to have_field("No - I can’t offer placements", type: :radio)
  end

  def and_i_see_a_success_message
    expect(page).to have_success_banner("Placement deleted", "You no longer have placement information available. Confirm your placement availability so providers know whether to contact you.")
  end
end
