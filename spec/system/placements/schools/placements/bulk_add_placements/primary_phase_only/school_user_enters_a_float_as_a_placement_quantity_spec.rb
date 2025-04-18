require "rails_helper"

RSpec.describe "School user enters a float as a placement quantity",
               service: :placements,
               type: :system do
  scenario do
    given_the_bulk_add_placements_flag_is_enabled
    and_subjects_exist
    and_academic_years_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    and_i_click_on_add_multiple_placements
    then_i_see_the_phase_form

    when_i_select_primary
    and_i_click_on_continue
    then_i_see_the_primary_subject_selection_form

    when_i_select_primary
    and_i_click_on_continue
    then_i_see_the_primary_subject_placement_quantity_form

    when_i_fill_in_the_number_of_primary_placements_with_a_float
    and_i_click_on_continue
    then_i_see_a_validation_error_for_not_entering_a_whole_number_quantity
  end

  private

  def given_the_bulk_add_placements_flag_is_enabled
    Flipper.add(:bulk_add_placements)
    Flipper.enable(:bulk_add_placements)
  end

  def and_subjects_exist
    @primary = create(:subject, :primary, name: "Primary")
    @phonics = create(:subject, :primary, name: "Phonics")
    @handwriting = create(:subject, :primary, name: "Handwriting")
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

  def when_i_am_on_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(page).to have_link("Add multiple placements")
  end
  alias_method :then_i_am_on_the_placements_index_page,
               :when_i_am_on_the_placements_index_page

  def when_i_click_on_add_multiple_placements
    click_on "Add multiple placements"
  end
  alias_method :and_i_click_on_add_multiple_placements,
               :when_i_click_on_add_multiple_placements

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_phase_form
    expect(page).to have_title(
      "What phase of education will your placements be? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "What phase of education will your placements be?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Secondary", type: :checkbox)
  end

  def when_i_select_primary
    check "Primary"
  end

  def then_i_see_the_primary_subject_selection_form
    expect(page).to have_title(
      "Select primary school subjects - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "Select primary school subjects",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Phonics", type: :checkbox)
    expect(page).to have_field("Handwriting", type: :checkbox)
  end

  def then_i_see_the_primary_subject_placement_quantity_form
    expect(page).to have_title(
      "Primary subjects: Enter the number of placements you would be willing to host - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Primary subjects: Enter the number of placements you would be willing to host", class: "govuk-heading-l")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_field("Primary", type: :number)
  end

  def when_i_fill_in_the_number_of_primary_placements_with_a_float
    fill_in "Primary", with: 2.3
  end

  def then_i_see_a_validation_error_for_not_entering_a_whole_number_quantity
    expect(page).to have_validation_error(
      "Primary must be a whole number",
    )
  end
end
