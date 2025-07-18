require "rails_helper"

RSpec.describe "Support user publishes a placement after preview", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_organisations_index_page
    and_i_select_hogwarts
    then_i_see_the_placements_index_page
    and_i_see_the_add_placement_button

    when_i_click_on_the_add_placement_button
    then_i_see_the_select_a_subject_page

    when_i_select_english
    and_i_click_on_continue
    then_i_see_the_select_an_academic_year_page

    when_i_select_next_year
    and_i_click_on_continue
    then_i_see_the_when_could_the_placement_take_place_page

    when_i_select_autumn_term_and_spring_term
    and_i_click_on_continue
    then_i_see_the_select_a_mentor_page

    when_i_select_a_mentor
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page
    and_i_see_the_placement_details

    # Test that the preview placement functionality works as expected
    when_i_click_on_preview_placement
    then_i_see_the_preview_placement_page

    # Test that publishing a placement works as expected
    when_i_click_on_publish_placement
    then_i_see_the_placements_index_page
    and_i_see_a_success_message
    and_i_see_my_placement
  end

  def given_that_placements_exist
    @school = create(
      :placements_school,
      name: "Hogwarts",
      address1: "Westgate Street",
      address2: "Hackney",
      postcode: "E8 3RL",
      group: "Local authority maintained schools",
      phase: "Secondary",
      gender: "Mixed",
      minimum_age: 11,
      maximum_age: 18,
      religious_character: "Does not apply",
      admissions_policy: "Not applicable",
      urban_or_rural: "(England/Wales) Urban major conurbation",
      percentage_free_school_meals: 15,
      rating: "Outstanding",
    )

    @secondary_english_subject = create(:subject, name: "English", subject_area: :secondary)

    @autumn_term = create(:placements_term, name: "Autumn term")
    @spring_term = create(:placements_term, name: "Spring term")
    @summer_term = create(:placements_term, name: "Summer term")

    @mentor_john_smith = create(:placements_mentor, first_name: "John", last_name: "Smith", schools: [@school])

    current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = current_academic_year.name
    @next_academic_year_name = current_academic_year.next.name
  end

  def and_i_am_signed_in
    sign_in_placements_support_user
  end

  def when_i_am_on_the_organisations_index_page
    expect(page).to have_title("Organisations (1) - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations (1)")
  end

  def and_i_select_hogwarts
    click_on "Hogwarts"
  end

  def then_i_see_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Hogwarts", class: "govuk-heading-s govuk-!-margin-bottom-0")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
  end

  def and_i_see_the_add_placement_button
    expect(page).to have_element(:a, text: "Add placement", class: "govuk-button")
  end

  def when_i_click_on_the_add_placement_button
    click_on "Add placement"
  end

  def then_i_see_the_select_a_subject_page
    expect(page).to have_title("Select a subject - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "Select a subject", class: "govuk-fieldset__legend")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/placements")
  end

  def when_i_click_on_continue
    click_on "Continue"
  end

  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def when_i_select_english
    choose "English"
  end

  def then_i_see_the_select_an_academic_year_page
    expect(page).to have_title("Select an academic year - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "Select an academic year", class: "govuk-fieldset__legend")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/placements")
  end

  def when_i_select_next_year
    choose "Next year (#{@next_academic_year_name})"
  end

  def then_i_see_the_when_could_the_placement_take_place_page
    expect(page).to have_title("Select when the placement could be - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:div, text: "Provide estimate term dates. You can discuss specific start and end dates with providers after the placement is published.", class: "govuk-hint")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/placements")
  end

  def when_i_select_autumn_term_and_spring_term
    uncheck "Any time in the academic year"
    check "Autumn term"
    check "Spring term"
  end

  def then_i_see_the_select_a_mentor_page
    expect(page).to have_title("Select who will mentor the trainee - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "Select who will mentor the trainee", class: "govuk-fieldset__legend")
    expect(page).to have_element(:div, text: "Only your school will be able to see the assigned mentor. Providers will not have access to this information.", class: "govuk-hint")
    expect(page).to have_element(:span, text: "My mentor is not listed", class: "govuk-details__summary-text")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/placements")
  end

  def when_i_select_a_mentor
    check "John Smith"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_paragraph("Publishing your placements will mean they are visible to teacher training providers. They will see your school has available placements.")
    expect(page).to have_button("Publish placement")
    expect(page).to have_element(:a, text: "Preview placement", class: "govuk-link")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/placements")
  end

  def and_i_see_the_placement_details
    expect(page).to have_summary_list_row("Subject", "English")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term, Spring term")
    expect(page).to have_summary_list_row("Mentor", "John Smith")
  end

  def when_i_click_on_preview_placement
    click_on "Preview placement"
  end

  def then_i_see_the_preview_placement_page
    expect(page).to have_title("Preview placement - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placement - Hogwarts English")
    expect(page).to have_important_banner("This is a preview of how your placement will appear to teacher training providers.")
    expect(page).to have_h2("Placement dates")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term, Spring term")
    expect(page).to have_h2("Placement contact")
    expect(page).to have_summary_list_row("First name", "Placement")
    expect(page).to have_summary_list_row("Last name", "Coordinator")
    expect(page).to have_summary_list_row("Email address", "placement_coordinator@example.school")
    expect(page).to have_h2("Location")
    expect(page).to have_summary_list_row("Address", "Westgate Street Hackney E8 3RL")
    expect(page).to have_h2("Additional details")
    expect(page).to have_summary_list_row("Establishment group", "Local authority maintained schools")
    expect(page).to have_summary_list_row("School phase", "Secondary")
    expect(page).to have_summary_list_row("Gender", "Mixed")
    expect(page).to have_summary_list_row("Age range", "11 to 18")
    expect(page).to have_summary_list_row("Religious character", "Does not apply")
    expect(page).to have_summary_list_row("Urban or rural", "(England/Wales) Urban major conurbation")
    expect(page).to have_summary_list_row("Admissions policy", "Not applicable")
    expect(page).to have_summary_list_row("Percentage free school meals", "15%")
    expect(page).to have_summary_list_row("Ofsted rating", "Outstanding")
  end

  def when_i_click_on_publish_placement
    click_on "Publish placement"
  end

  def then_i_see_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
  end

  def and_i_see_a_success_message
    expect(page).to have_success_banner("Placement added")
  end

  def and_i_see_my_placement
    expect(page).to have_element(:td, text: "English", class: "govuk-table__cell")
    expect(page).to have_element(:td, text: "John Smith", class: "govuk-table__cell")
    expect(page).to have_element(:td, text: "Autumn term, Spring term", class: "govuk-table__cell")
    expect(page).to have_element(:td, text: "Provider not assigned", class: "govuk-table__cell")
  end
end
