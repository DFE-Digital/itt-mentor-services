require "rails_helper"

RSpec.describe "School user adds their hosting interest and bulk adds placements for the secondary phase",
               service: :placements,
               type: :system do
  scenario do
    given_subjects_exist
    and_academic_years_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    and_i_click_on_add_multiple_placements
    then_i_see_the_phase_form

    when_i_select_secondary
    and_i_click_on_continue
    then_i_see_the_secondary_subject_selection_form

    when_i_select_english
    and_i_select_mathematics
    and_i_click_on_continue
    then_i_see_the_secondary_subject_placement_quantity_form

    when_i_fill_in_the_number_of_secondary_placements_i_require
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_publish_placements
    then_i_see_the_whats_next_page
    and_i_see_1_secondary_placement_for_english_has_been_created
    and_i_see_4_secondary_placement_for_mathematics_have_been_created

    when_i_click_on_edit_your_placements
    then_i_am_on_the_placements_index_page
    and_i_see_1_secondary_placement_for_english
    and_i_see_4_secondary_placements_for_mathematics
  end

  private

  def given_subjects_exist
    @english = create(:subject, :secondary, name: "English")
    @mathematics = create(:subject, :secondary, name: "Mathematics")
    @science = create(:subject, :secondary, name: "Science")
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

  def when_i_select_secondary
    check "Secondary"
  end

  def then_i_see_the_secondary_subject_selection_form
    expect(page).to have_title(
      "What secondary school subjects can you offer placements in? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "What secondary school subjects can you offer placements in?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_element(:span, text: "Secondary placement details", class: "govuk-caption-l")
    expect(page).to have_field("English", type: :checkbox)
    expect(page).to have_field("Mathematics", type: :checkbox)
    expect(page).to have_field("Science", type: :checkbox)
  end

  def when_i_select_english
    check "English"
  end

  def and_i_select_mathematics
    check "Mathematics"
  end

  def then_i_see_the_secondary_subject_placement_quantity_form
    expect(page).to have_title(
      "How many placements can you offer for each subject? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("How many placements can you offer for each subject?", class: "govuk-heading-l")
    expect(page).to have_element(:span, text: "Secondary placement details", class: "govuk-caption-l")
    expect(page).to have_field("English", type: :number)
    expect(page).to have_field("Mathematics", type: :number)
  end

  def when_i_fill_in_the_number_of_secondary_placements_i_require
    fill_in "English", with: 1
    fill_in "Mathematics", with: 4
  end

  def then_i_see_my_responses_were_successfully_updated
    expect(page).to have_success_banner(
      "Placements added",
      "Providers can see your placements and may contact you to discuss them. You can add details to your placements such as expected date and provider.",
    )
  end

  def and_i_see_1_secondary_placement_for_english
    expect(page).to have_link(
      "English",
      class: "govuk-link govuk-link--no-visited-state",
      match: :prefer_exact,
      count: 1,
    )
  end

  def and_i_see_4_secondary_placements_for_mathematics
    expect(page).to have_link(
      "Mathematics",
      class: "govuk-link govuk-link--no-visited-state",
      match: :prefer_exact,
      count: 4,
    )
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
    expect(page).to have_summary_list_row("Phase", "Secondary")

    expect(page).to have_h2("Secondary placements")
    expect(page).to have_summary_list_row("English", "1")
    expect(page).to have_summary_list_row("Mathematics", "4")

    expect(page).not_to have_h2("Providers")
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
    expect(page).not_to have_h3("Primary placements", class: "govuk-heading-s")
    expect(page).to have_h3("Secondary placements", class: "govuk-heading-s")
  end

  def when_i_click_on_edit_your_placements
    click_on "Edit your placements"
  end

  def and_i_see_1_secondary_placement_for_english_has_been_created
    expect(page).to have_summary_list_row("English", "1")
  end

  def and_i_see_4_secondary_placement_for_mathematics_have_been_created
    expect(page).to have_summary_list_row("Mathematics", "4")
  end
end
