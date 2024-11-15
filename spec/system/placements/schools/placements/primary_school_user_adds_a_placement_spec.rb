require "rails_helper"

RSpec.describe "Primary school user adds a placement", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_the_add_placement_button

    # Test that each step of the wizard is working as expected
    when_i_click_on_the_add_placement_button
    then_i_see_the_select_a_subject_page
    and_i_see_the_primary_subjects
    and_i_do_not_see_the_secondary_subjects

    when_i_click_on_the_back_link
    then_i_see_the_placements_index_page

    when_i_click_on_the_add_placement_button
    when_i_click_on_continue
    then_i_see_a_validation_error_for_selecting_a_subject

    when_i_select_primary_with_english
    and_i_click_on_continue
    then_i_see_the_select_a_year_group_page
    and_i_see_the_primary_year_groups

    when_i_click_on_continue
    then_i_see_a_validation_error_for_selecting_a_year_group

    when_i_select_year_1
    and_i_click_on_continue
    then_i_see_the_select_an_academic_year_page
    and_i_see_the_academic_years

    when_i_click_on_continue
    then_i_see_a_validation_error_for_selecting_a_academic_year

    when_i_select_this_year
    and_i_click_on_continue
    then_i_see_the_when_could_the_placement_take_place_page
    and_i_see_the_term_dates

    when_i_click_on_continue
    then_i_see_a_validation_error_for_selecting_a_term

    when_i_select_autumn_term_and_spring_term
    and_i_click_on_continue
    then_i_see_the_select_a_mentor_page
    and_i_see_the_available_mentors

    when_i_click_on_my_mentor_is_not_listed
    then_i_see_the_mentor_not_listed_details_text

    when_i_click_on_continue
    then_i_see_a_validation_error_for_selecting_a_mentor

    when_i_select_a_mentor
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page
    and_i_see_the_placement_details

    # Test that the back link navigation works as expected
    when_i_click_on_the_back_link
    then_i_see_the_select_a_mentor_page

    when_i_click_on_the_back_link
    then_i_see_the_when_could_the_placement_take_place_page

    when_i_click_on_the_back_link
    then_i_see_the_select_an_academic_year_page

    when_i_click_on_the_back_link
    then_i_see_the_select_a_year_group_page

    when_i_click_on_the_back_link
    then_i_see_the_select_a_subject_page

    # Test that the change link functionality works as expected
    when_i_continue_from_the_subject_page_to_the_check_your_answers_page
    and_i_change_the_subject
    then_i_see_the_select_a_subject_page
    and_i_see_primary_with_english_is_selected

    when_i_select_primary_with_maths
    and_i_continue_from_the_subject_page_to_the_check_your_answers_page
    then_i_see_the_check_your_answers_page_with_updated_subject

    when_i_change_the_year_group
    then_i_see_the_select_a_year_group_page
    and_i_see_year_1_is_selected

    when_i_select_year_2
    and_i_continue_from_the_year_group_page_to_the_check_your_answers_page
    then_i_see_the_check_your_answers_page_with_updated_year_group

    when_i_change_the_academic_year
    then_i_see_the_select_an_academic_year_page
    and_i_see_this_year_is_selected

    when_i_select_next_year
    and_i_continue_from_the_academic_year_page_to_the_check_your_answers_page
    then_i_see_the_check_your_answers_page_with_updated_academic_year

    when_i_change_the_term
    then_i_see_the_when_could_the_placement_take_place_page
    and_i_see_autumn_term_and_spring_term_are_selected

    when_i_select_summer_term
    and_i_continue_from_the_term_page_to_the_check_your_answers_page
    then_i_see_the_check_your_answers_page_with_updated_term

    when_i_change_the_mentor
    then_i_see_the_select_a_mentor_page
    and_i_see_john_smith_is_selected

    when_i_select_jane_doe
    and_i_continue_from_the_mentor_page_to_the_check_your_answers_page
    then_i_see_the_check_your_answers_page_with_updated_mentor

    # Test that the preview placement functionality works as expected
    when_i_click_on_preview_placement
    then_i_see_the_preview_placement_page

    when_i_click_on_edit_placement
    then_i_see_the_check_your_answers_page

    # Test that publishing a placement works as expected
    when_i_click_on_publish_placement
    then_i_see_the_placement_placements_index_page
    and_i_see_a_success_message

    when_i_click_on_next_year
    then_i_see_my_placement
  end

  def given_that_placements_exist
    @school = create(
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

    @primary_english_subject = create(:subject, name: "Primary with english", subject_area: :primary)
    @primary_maths_subject = create(:subject, name: "Primary with mathematics", subject_area: :primary)
    @secondary_english_subject = create(:subject, name: "English", subject_area: :secondary)
    @secondary_maths_subject = create(:subject, name: "Mathematics", subject_area: :secondary)

    @autumn_term = create(:placements_term, name: "Autumn term")
    @spring_term = create(:placements_term, name: "Spring term")
    @summer_term = create(:placements_term, name: "Summer term")

    @mentor_john_smith = create(:placements_mentor, first_name: "John", last_name: "Smith", schools: [@school])
    @mentor_jane_doe = create(:placements_mentor, first_name: "Jane", last_name: "Doe", schools: [@school])

    current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = current_academic_year.name
    @next_academic_year_name = current_academic_year.next.name
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_am_on_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(secondary_navigation).to have_current_item("This year (#{@current_academic_year_name}")
  end

  alias_method :then_i_see_the_placements_index_page, :when_i_am_on_the_placements_index_page

  def then_i_see_the_add_placement_button
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

  def and_i_see_the_primary_subjects
    expect(page).to have_field("Primary with english", type: :radio)
    expect(page).to have_field("Primary with mathematics", type: :radio)
  end

  def and_i_do_not_see_the_secondary_subjects
    expect(page).not_to have_field("English", type: :radio)
    expect(page).not_to have_field("Mathematics", type: :radio)
  end

  def when_i_click_on_the_back_link
    click_on "Back"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end

  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def then_i_see_a_validation_error_for_selecting_a_subject
    expect(page).to have_validation_error("Select a subject")
  end

  def when_i_select_primary_with_english
    choose "Primary with english"
  end

  def then_i_see_the_select_a_year_group_page
    expect(page).to have_title("Select a year group - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "Select a year group", class: "govuk-fieldset__legend")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/placements")
  end

  def and_i_see_the_primary_year_groups
    expect(page).to have_field("Nursery", type: :radio)
    expect(page).to have_element(:div, text: "3 to 4 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Reception", type: :radio)
    expect(page).to have_element(:div, text: "4 to 5 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Year 1", type: :radio)
    expect(page).to have_element(:div, text: "5 to 6 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Year 2", type: :radio)
    expect(page).to have_element(:div, text: "6 to 7 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Year 3", type: :radio)
    expect(page).to have_element(:div, text: "7 to 8 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Year 4", type: :radio)
    expect(page).to have_element(:div, text: "8 to 9 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Year 5", type: :radio)
    expect(page).to have_element(:div, text: "9 to 10 years", class: "govuk-hint govuk-radios__hint")
    expect(page).to have_field("Year 6", type: :radio)
    expect(page).to have_element(:div, text: "10 to 11 years", class: "govuk-hint govuk-radios__hint")
  end

  def then_i_see_a_validation_error_for_selecting_a_year_group
    expect(page).to have_validation_error("Select a year group")
  end

  def when_i_select_year_1
    choose "Year 1"
  end

  def then_i_see_the_select_an_academic_year_page
    expect(page).to have_title("Select an academic year - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "Select an academic year", class: "govuk-fieldset__legend")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/placements")
  end

  def and_i_see_the_academic_years
    expect(page).to have_field("This year (#{@current_academic_year_name})", type: :radio)
    expect(page).to have_field("Next year (#{@next_academic_year_name})", type: :radio)
  end

  def then_i_see_a_validation_error_for_selecting_a_academic_year
    expect(page).to have_validation_error("Select an academic year")
  end

  def when_i_select_this_year
    choose "This year (#{@current_academic_year_name})"
  end

  def then_i_see_the_when_could_the_placement_take_place_page
    expect(page).to have_title("Select when the placement could be - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:div, text: "Provide estimate term dates. You can discuss specific start and end dates with providers after the placement is published.", class: "govuk-hint")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/placements")
  end

  def and_i_see_the_term_dates
    expect(page).to have_field("Autumn term", type: :checkbox)
    expect(page).to have_field("Spring term", type: :checkbox)
    expect(page).to have_field("Summer term", type: :checkbox)
    expect(page).to have_field("Any time in the academic year", type: :checkbox)
  end

  def then_i_see_a_validation_error_for_selecting_a_term
    expect(page).to have_validation_error("Select a term")
  end

  def when_i_select_autumn_term_and_spring_term
    check "Autumn term"
    check "Spring term"
  end

  def then_i_see_the_select_a_mentor_page
    expect(page).to have_title("Select a mentor - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:legend, text: "Select a mentor", class: "govuk-fieldset__legend")
    expect(page).to have_element(:div, text: "Some placements may have more than one mentor. For example, if a mentor works part time. You can change who the mentor is after you have published the placement.", class: "govuk-hint")
    expect(page).to have_element(:span, text: "My mentor is not listed", class: "govuk-details__summary-text")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/placements")
  end

  def when_i_click_on_my_mentor_is_not_listed
    # click_on does not work for this element
    find("span.govuk-details__summary-text", text: "My mentor is not listed").click
  end

  def then_i_see_the_mentor_not_listed_details_text
    expect(page).to have_element(:div, text: "You must add mentors to your school's profile before they can be assigned to a specific placement.", class: "govuk-details__text")
    expect(page).to have_link("add mentors to your school's profile", href: "/schools/#{@school.id}/mentors/new")
  end

  def and_i_see_the_available_mentors
    expect(page).to have_field("John Smith", type: :checkbox)
    expect(page).to have_field("Jane Doe", type: :checkbox)
    expect(page).to have_field("Not yet known", type: :checkbox)
  end

  def then_i_see_a_validation_error_for_selecting_a_mentor
    expect(page).to have_validation_error("Select a mentor")
  end

  def when_i_select_a_mentor
    check "John Smith"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_element(:div, text: "When a placement is published, it will be visible to teacher training providers.", class: "govuk-inset-text")
    expect(page).to have_button("Publish placement")
    expect(page).to have_element(:a, text: "Preview placement", class: "govuk-link")
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/placements")
  end

  def and_i_see_the_placement_details
    expect(page).to have_summary_list_row("Subject", "Primary with english")
    expect(page).to have_summary_list_row("Year group", "Year 1")
    expect(page).to have_summary_list_row("Academic year", "This year (#{@current_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term, Spring term")
    expect(page).to have_summary_list_row("Mentor", "John Smith")
  end

  def and_i_change_the_subject
    click_on "Change Subject"
  end

  def and_i_continue_from_the_subject_page_to_the_check_your_answers_page
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
  end

  alias_method :when_i_continue_from_the_subject_page_to_the_check_your_answers_page, :and_i_continue_from_the_subject_page_to_the_check_your_answers_page

  def and_i_see_primary_with_english_is_selected
    expect(page).to have_checked_field("Primary with english")
  end

  def when_i_select_primary_with_maths
    choose "Primary with mathematics"
  end

  def then_i_see_the_check_your_answers_page_with_updated_subject
    expect(page).to have_summary_list_row("Subject", "Primary with mathematics")
    expect(page).to have_summary_list_row("Year group", "Year 1")
    expect(page).to have_summary_list_row("Academic year", "This year (#{@current_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term, Spring term")
    expect(page).to have_summary_list_row("Mentor", "John Smith")
  end

  def when_i_change_the_year_group
    click_on "Change Year group"
  end

  def and_i_see_year_1_is_selected
    expect(page).to have_checked_field("Year 1")
  end

  def when_i_select_year_2
    choose "Year 2"
  end

  def and_i_continue_from_the_year_group_page_to_the_check_your_answers_page
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page_with_updated_year_group
    expect(page).to have_summary_list_row("Subject", "Primary with mathematics")
    expect(page).to have_summary_list_row("Year group", "Year 2")
    expect(page).to have_summary_list_row("Academic year", "This year (#{@current_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term, Spring term")
    expect(page).to have_summary_list_row("Mentor", "John Smith")
  end

  def when_i_change_the_academic_year
    click_on "Change Academic year"
  end

  def and_i_see_this_year_is_selected
    expect(page).to have_checked_field("This year (#{@current_academic_year_name})")
  end

  def when_i_select_next_year
    choose "Next year (#{@next_academic_year_name})"
  end

  def and_i_continue_from_the_academic_year_page_to_the_check_your_answers_page
    click_on "Continue"
    click_on "Continue"
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page_with_updated_academic_year
    expect(page).to have_summary_list_row("Subject", "Primary with mathematics")
    expect(page).to have_summary_list_row("Year group", "Year 2")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Autumn term, Spring term")
    expect(page).to have_summary_list_row("Mentor", "John Smith")
  end

  def when_i_change_the_term
    click_on "Change Expected date"
  end

  def and_i_see_autumn_term_and_spring_term_are_selected
    expect(page).to have_checked_field("Autumn term")
    expect(page).to have_checked_field("Spring term")
  end

  def when_i_select_summer_term
    uncheck "Autumn term"
    uncheck "Spring term"
    check "Summer term"
  end

  def and_i_continue_from_the_term_page_to_the_check_your_answers_page
    click_on "Continue"
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page_with_updated_term
    expect(page).to have_summary_list_row("Subject", "Primary with mathematics")
    expect(page).to have_summary_list_row("Year group", "Year 2")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Summer term")
    expect(page).to have_summary_list_row("Mentor", "John Smith")
  end

  def when_i_change_the_mentor
    click_on "Change Mentor"
  end

  def and_i_see_john_smith_is_selected
    expect(page).to have_checked_field("John Smith")
  end

  def when_i_select_jane_doe
    uncheck "John Smith"
    check "Jane Doe"
  end

  def and_i_continue_from_the_mentor_page_to_the_check_your_answers_page
    click_on "Continue"
  end

  def then_i_see_the_check_your_answers_page_with_updated_mentor
    expect(page).to have_summary_list_row("Subject", "Primary with mathematics")
    expect(page).to have_summary_list_row("Year group", "Year 2")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Summer term")
    expect(page).to have_summary_list_row("Mentor", "Jane Doe")
  end

  def when_i_click_on_preview_placement
    click_on "Preview placement"
  end

  def then_i_see_the_preview_placement_page
    expect(page).to have_title("Preview placement - Placement details - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placement - Springfield Elementary Primary with mathematics (Year 2)")
    expect(page).to have_important_banner("This is a preview of how your placement will appear to teacher training providers.")
    expect(page).to have_h2("Placement dates")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Summer term")
    expect(page).to have_h2("Placement contact")
    expect(page).to have_summary_list_row("First name", "Placement")
    expect(page).to have_summary_list_row("Last name", "Coordinator")
    expect(page).to have_summary_list_row("Email address", "placement_coordinator@example.school")
    expect(page).to have_h2("Location")
    expect(page).to have_summary_list_row("Address", "Westgate Street Hackney E8 3RL")
    expect(page).to have_h2("Additional details")
    expect(page).to have_summary_list_row("Establishment group", "Local authority maintained schools")
    expect(page).to have_summary_list_row("School phase", "Primary")
    expect(page).to have_summary_list_row("Gender", "Mixed")
    expect(page).to have_summary_list_row("Age range", "3 to 11")
    expect(page).to have_summary_list_row("Religious character", "Does not apply")
    expect(page).to have_summary_list_row("Urban or rural", "(England/Wales) Urban major conurbation")
    expect(page).to have_summary_list_row("Admissions policy", "Not applicable")
    expect(page).to have_summary_list_row("Percentage free school meals", "15%")
    expect(page).to have_summary_list_row("Ofsted rating", "Outstanding")
  end

  def when_i_click_on_edit_placement
    click_on "Edit placement"
  end

  def when_i_click_on_publish_placement
    click_on "Publish placement"
  end

  def then_i_see_the_placement_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
  end

  def and_i_see_a_success_message
    expect(page).to have_success_banner("Placement added")
  end

  def when_i_click_on_next_year
    click_on "Next year (#{@next_academic_year_name})"
  end

  def then_i_see_my_placement
    expect(page).to have_table_row({
      "Subject" => "Primary with mathematics (Year 2)",
      "Mentor" => "Jane Doe",
      "Expected date" => "Summer term",
      "Provider" => "Not yet known",
    })
  end
end
