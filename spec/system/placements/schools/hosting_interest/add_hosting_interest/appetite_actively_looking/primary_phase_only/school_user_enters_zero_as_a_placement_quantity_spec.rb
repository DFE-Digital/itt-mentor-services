require "rails_helper"

RSpec.describe "School user enters zero as a placement quantity",
               service: :placements,
               type: :system do
  scenario do
    given_subjects_exist
    and_academic_years_exist
    and_i_am_signed_in

    when_i_visit_the_add_hosting_interest_page
    then_i_see_the_appetite_form

    when_i_select_actively_looking_to_host_placements
    and_i_click_on_continue
    then_i_see_the_phase_form

    when_i_select_primary
    and_i_click_on_continue
    then_i_see_the_primary_year_group_selection_form

    when_i_select_year_1
    and_i_click_on_continue
    then_i_see_the_primary_placement_quantity_form

    when_i_fill_in_the_number_of_year_1_placements_with_zero
    and_i_click_on_continue
    then_i_see_a_validation_error_for_entering_a_zero_quantity
  end

  private

  def given_subjects_exist
    @primary = create(:subject, :primary, name: "Primary")
  end

  def and_academic_years_exist
    current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = current_academic_year.name
    @next_academic_year = current_academic_year.next
    @next_academic_year_name = @next_academic_year.name
  end

  def and_i_am_signed_in
    @school = create(:placements_school)
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_visit_the_add_hosting_interest_page
    visit new_add_hosting_interest_placements_school_hosting_interests_path(@school)
  end

  def then_i_see_the_appetite_form
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

  def when_i_select_actively_looking_to_host_placements
    choose "Yes - I can offer placements"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_phase_form
    expect(page).to have_title(
      "What education phase can your placements be? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "What education phase can your placements be?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Secondary", type: :checkbox)
  end

  def when_i_select_primary
    check "Primary"
  end

  def then_i_see_the_primary_year_group_selection_form
    expect(page).to have_title(
      "hat primary school year groups can you offer placements in? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "What primary school year groups can you offer placements in?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_element(:span, text: "Primary placement details", class: "govuk-caption-l")
    expect(page).to have_field("Nursery", type: :checkbox)
    expect(page).to have_field("Reception", type: :checkbox)
    expect(page).to have_field("Year 1", type: :checkbox)
    expect(page).to have_field("Year 2", type: :checkbox)
    expect(page).to have_field("Year 3", type: :checkbox)
    expect(page).to have_field("Year 4", type: :checkbox)
    expect(page).to have_field("Year 5", type: :checkbox)
    expect(page).to have_field("Year 6", type: :checkbox)
    expect(page).to have_field("Mixed year groups", type: :checkbox)
  end

  def when_i_select_year_1
    check "Year 1"
  end

  def then_i_see_the_primary_placement_quantity_form
    expect(page).to have_title(
      "Enter the number of primary school placements you can offer - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Enter the number of primary school placements you can offer", class: "govuk-heading-l")
    expect(page).to have_element(:span, text: "Primary placement details", class: "govuk-caption-l")
    expect(page).to have_field("Year 1", type: :number)
  end

  def when_i_fill_in_the_number_of_year_1_placements_with_zero
    fill_in "Year 1", with: 0
  end

  def then_i_see_a_validation_error_for_entering_a_zero_quantity
    expect(page).to have_validation_error(
      "Year 1 must be greater than 0",
    )
  end
end
