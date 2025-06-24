require "rails_helper"

RSpec.describe "School user bulk adds placements for the primary phases",
               service: :placements,
               type: :system do
  scenario do
    given_subjects_exist
    and_academic_years_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    and_i_click_on_add_multiple_placements
    then_i_see_the_phase_form

    when_i_select_primary
    and_i_click_on_continue
    then_i_see_the_primary_year_group_selection_form

    when_i_select_reception
    and_i_select_year_3
    and_i_select_mixed_year_groups
    and_i_click_on_continue
    then_i_see_the_primary_placement_quantity_form

    when_i_fill_in_the_number_of_primary_placements_i_require
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_publish_placements
    then_i_see_the_whats_next_page
    and_i_see_2_reception_primary_placements_have_been_created
    and_i_see_3_year_3_primary_placements_have_been_created
    and_i_see_1_mixed_year_groups_primary_placement_has_been_created

    when_i_click_on_edit_your_placements
    then_i_am_on_the_placements_index_page
    and_i_see_2_primary_placements_for_reception
    and_i_see_3_primary_placements_for_year_3
    and_i_see_1_primary_placements_for_mixed_year_groups
  end

  private

  def given_subjects_exist
    @primary = create(:subject, :primary, name: "Primary", code: "00")
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
      "What education phase can your placements be? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "What education phase can your placements be?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_hint("Select all that apply")
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Secondary", type: :checkbox)
  end

  def when_i_select_primary
    check "Primary"
  end

  def then_i_see_the_primary_year_group_selection_form
    expect(page).to have_title(
      "What primary school year groups can you offer placements in? - Manage school placements - GOV.UK",
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

  def when_i_select_reception
    check "Reception"
  end

  def and_i_select_year_3
    check "Year 3"
  end

  def and_i_select_mixed_year_groups
    check "Mixed year groups"
  end

  def then_i_see_the_primary_placement_quantity_form
    expect(page).to have_title(
      "Enter the number of primary school placements you can offer - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Enter the number of primary school placements you can offer", class: "govuk-heading-l")
    expect(page).to have_element(:span, text: "Primary placement details", class: "govuk-caption-l")
    expect(page).to have_field("Reception", type: :number)
    expect(page).to have_field("Year 3", type: :number)
    expect(page).to have_field("Mixed year groups", type: :number)
  end

  def when_i_fill_in_the_number_of_primary_placements_i_require
    fill_in "Reception", with: 2
    fill_in "Year 3", with: 3
    fill_in "Mixed year groups", with: 1
  end

  def and_i_see_2_primary_placements_for_reception
    expect(page).to have_link("Primary (Reception)", count: 2)
  end

  def and_i_see_3_primary_placements_for_year_3
    expect(page).to have_link("Primary (Year 3)", count: 3)
  end

  def and_i_see_1_primary_placements_for_mixed_year_groups
    expect(page).to have_link("Primary (Mixed year groups)")
  end

  def when_i_click_on_publish_placements
    click_on "Publish placements"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title(
      "Check your answers - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Check your answers")

    expect(page).to have_h2("Education phase")
    expect(page).to have_summary_list_row("Phase", "Primary")

    expect(page).to have_h2("Primary placements")
    expect(page).to have_summary_list_row("Reception", "2")
    expect(page).to have_summary_list_row("Year 3", "3")
    expect(page).to have_summary_list_row("Mixed year group", "1")
  end

  def then_i_see_the_whats_next_page
    expect(page).to have_title(
      "What happens next? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_panel(
      "Placement information added",
      "Providers can see that you have placements available",
    )
    expect(page).to have_h1("What happens next?", class: "govuk-heading-l")
    expect(page).to have_paragraph("Providers will be able to contact you on #{@school.school_contact_email_address} about your placement offers")
    expect(page).to have_h2("Manage your placements", class: "govuk-heading-m")
    expect(page).to have_h2("Your placements offer", class: "govuk-heading-m")
    expect(page).to have_h3("Primary placements", class: "govuk-heading-s")
    expect(page).not_to have_h3("Secondary placements", class: "govuk-heading-s")
  end

  def when_i_click_on_edit_your_placements
    click_on "Edit your placements"
  end

  def and_i_see_2_reception_primary_placements_have_been_created
    expect(page).to have_summary_list_row("Reception", "2")
  end

  def and_i_see_3_year_3_primary_placements_have_been_created
    expect(page).to have_summary_list_row("Year 3", "3")
  end

  def and_i_see_1_mixed_year_groups_primary_placement_has_been_created
    expect(page).to have_summary_list_row("Mixed year groups", "1")
  end
end
