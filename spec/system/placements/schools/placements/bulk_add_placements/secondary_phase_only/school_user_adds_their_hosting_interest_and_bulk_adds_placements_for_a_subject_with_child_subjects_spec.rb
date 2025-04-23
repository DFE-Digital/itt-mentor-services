require "rails_helper"

RSpec.describe "School user adds their hosting interest and bulk adds placements for a subject with child subjects",
               service: :placements,
               type: :system do
  scenario do
    given_subjects_exist
    and_academic_years_exist
    and_test_providers_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    and_i_click_on_add_multiple_placements
    then_i_see_the_phase_form

    when_i_select_secondary
    and_i_click_on_continue
    then_i_see_the_secondary_subject_selection_form

    when_i_select_modern_languages
    and_i_click_on_continue
    then_i_see_the_secondary_subject_placement_quantity_form

    when_i_fill_in_the_number_of_secondary_placements_i_require
    and_i_click_on_continue
    then_i_see_the_subject_selection_for_modern_languages_form
    and_i_see_the_form_is_for_the_first_placement

    when_i_select_french
    and_i_click_on_continue
    then_i_see_the_subject_selection_for_modern_languages_form
    and_i_see_the_form_is_for_the_second_placement

    when_i_select_spanish
    and_i_select_russian
    and_i_click_on_continue
    then_i_see_the_provider_select_form

    when_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_save_and_continue
    then_i_see_my_responses_with_successfully_updated
    and_i_see_placements_i_created_for_the_subject_french
    and_i_see_placements_i_created_for_the_subject_french_and_russian
  end

  private

  def given_subjects_exist
    @english = create(:subject, :secondary, name: "English")
    @mathematics = create(:subject, :secondary, name: "Mathematics")
    @science = create(:subject, :secondary, name: "Science")
    @modern_languages = create(:subject, :secondary, name: "Modern languages")
    @french = create(:subject, :secondary, name: "French", parent_subject: @modern_languages)
    @spanish = create(:subject, :secondary, name: "Spanish", parent_subject: @modern_languages)
    @russian = create(:subject, :secondary, name: "Russian", parent_subject: @modern_languages)
  end

  def and_academic_years_exist
    current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = current_academic_year.name
    @next_academic_year = current_academic_year.next
    @next_academic_year_name = @next_academic_year.name
  end

  def and_test_providers_exist
    @provider_1 = create(:provider, name: "Test Provider 123")
    @provider_2 = create(:provider, name: "Test Provider 456")
    @provider_3 = create(:provider, name: "Test Provider 789")
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

  def when_i_select_secondary
    check "Secondary"
  end

  def then_i_see_the_secondary_subject_selection_form
    expect(page).to have_title(
      "Select secondary school subjects - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "Select secondary school subjects",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_field("English", type: :checkbox)
    expect(page).to have_field("Mathematics", type: :checkbox)
    expect(page).to have_field("Science", type: :checkbox)
    expect(page).to have_field("Modern languages", type: :checkbox)
  end

  def when_i_select_modern_languages
    check "Modern languages"
  end

  def then_i_see_the_secondary_subject_placement_quantity_form
    expect(page).to have_title(
      "Secondary subjects: Enter the number of placements you would be willing to host - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Secondary subjects: Enter the number of placements you would be willing to host", class: "govuk-heading-l")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_field("Modern languages", type: :number)
  end

  def when_i_fill_in_the_number_of_secondary_placements_i_require
    fill_in "Modern languages", with: 2
  end

  def then_i_see_the_subject_selection_for_modern_languages_form
    expect(page).to have_title(
      "You selected 2 Modern languages placements - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1(
      "You selected 2 Modern languages placements",
      class: "govuk-heading-l",
    )
    expect(page).to have_h2(
      "Select the languages taught on each of these placements",
      class: "govuk-heading-m",
    )
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_field("French", type: :checkbox)
    expect(page).to have_field("Spanish", type: :checkbox)
    expect(page).to have_field("Russian", type: :checkbox)
  end

  def when_i_select_french
    check "French"
  end

  def when_i_select_spanish
    check "Spanish"
  end

  def and_i_select_russian
    check "Russian"
  end

  def and_i_see_the_form_is_for_the_first_placement
    expect(page).to have_element(:h2, text: "Placement 1 of 2", class: "govuk-fieldset__heading")
  end

  def and_i_see_the_form_is_for_the_second_placement
    expect(page).to have_element(:h2, text: "Placement 2 of 2", class: "govuk-fieldset__heading")
  end

  def then_i_see_my_responses_with_successfully_updated
    expect(page).to have_success_banner(
      "Placements added",
      "Providers can see your placements and may contact you to discuss them. You can add details to your placements such as expected date and provider.",
    )
  end

  def and_i_see_placements_i_created_for_the_subject_french
    expect(page).to have_link(
      "French",
      class: "govuk-link govuk-link--no-visited-state",
      match: :prefer_exact,
      count: 1,
    )
  end

  def and_i_see_placements_i_created_for_the_subject_french_and_russian
    expect(page).to have_link(
      "Russian and Spanish",
      class: "govuk-link govuk-link--no-visited-state",
      match: :prefer_exact,
      count: 1,
    )
  end

  def then_i_see_the_provider_select_form
    expect(page).to have_title(
      "Select the providers you currently work with - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :h1,
      text: "Select the providers you currently work with",
      class: "govuk-fieldset__heading",
    )
    expect(page).to have_field("Select all", type: :checkbox)
    expect(page).to have_field("Test Provider 123", type: :checkbox)
    expect(page).to have_field("Test Provider 456", type: :checkbox)
    expect(page).to have_field("Test Provider 789", type: :checkbox)
  end

  def when_i_click_save_and_continue
    click_on "Save and continue"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title(
      "Check your answers - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Check your answers")

    expect(page).to have_h2("Education phase")
    expect(page).to have_summary_list_row("Phase", "Secondary")

    expect(page).to have_h2("Placements")
    expect(page).to have_summary_list_row("Modern languages", "2")

    expect(page).not_to have_h2("Providers")
  end
end
