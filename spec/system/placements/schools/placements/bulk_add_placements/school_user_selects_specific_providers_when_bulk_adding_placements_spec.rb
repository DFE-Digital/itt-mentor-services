require "rails_helper"

RSpec.describe "School user selects specfic providers when bulk adding placements",
               service: :placements,
               type: :system do
  scenario do
    given_the_bulk_add_placements_flag_is_enabled
    and_the_school_partner_providers_flag_is_enabled
    and_subjects_exist
    and_test_providers_exist
    and_academic_years_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    and_i_click_on_bulk_add_placements
    then_i_see_the_phase_form

    when_i_select_primary
    and_i_select_secondary
    and_i_click_on_continue
    then_i_see_the_primary_subject_selection_form

    when_i_select_primary
    and_i_select_primary_with_science
    and_i_click_on_continue
    then_i_see_the_primary_subject_placement_quantity_form

    when_i_fill_in_the_number_of_primary_placements_i_require
    and_i_click_on_continue
    then_i_see_the_secondary_subject_selection_form

    when_i_select_english
    and_i_select_mathematics
    and_i_click_on_continue
    then_i_see_the_secondary_subject_placement_quantity_form

    when_i_fill_in_the_number_of_secondary_placements_i_require
    and_i_click_on_continue
    then_i_see_the_provider_select_form

    when_i_select_provider_123
    and_i_select_provider_789
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_save_and_continue
    then_i_see_my_responses_with_successfully_updated
    and_i_see_placements_i_created_for_the_subject_primary
    and_i_see_placements_i_created_for_the_subject_handwriting
    and_i_see_placements_i_created_for_the_subject_english
    and_i_see_placements_i_created_for_the_subject_mathematics

    when_i_click_on_the_providers_navigation
    then_i_see_test_provider_123
    and_i_see_test_provider_789
    and_i_do_not_see_test_provider_456
  end

  private

  def given_the_bulk_add_placements_flag_is_enabled
    Flipper.add(:bulk_add_placements)
    Flipper.enable(:bulk_add_placements)
  end

  def and_the_school_partner_providers_flag_is_enabled
    Flipper.add(:school_partner_providers)
    Flipper.enable(:school_partner_providers)
  end

  def and_subjects_exist
    @primary = create(:subject, :primary, name: "Primary")
    @phonics = create(:subject, :primary, name: "Phonics")
    @handwriting = create(:subject, :primary, name: "Handwriting")

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
    expect(secondary_navigation).to have_current_item("This year (#{@current_academic_year_name}")
    expect(page).to have_link("Bulk add placements")
  end
  alias_method :then_i_am_on_the_placements_index_page,
               :when_i_am_on_the_placements_index_page

  def when_i_click_on_bulk_add_placements
    click_on "Bulk add placements"
  end
  alias_method :and_i_click_on_bulk_add_placements,
               :when_i_click_on_bulk_add_placements

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

  def and_i_select_secondary
    check "Secondary"
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

  def and_i_select_primary_with_science
    check "Handwriting"
  end

  def then_i_see_the_primary_subject_placement_quantity_form
    expect(page).to have_title(
      "Primary subjects: Enter the number of placements you would be willing to host - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Primary subjects: Enter the number of placements you would be willing to host", class: "govuk-heading-l")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_field("Primary", type: :number)
    expect(page).to have_field("Handwriting", type: :number)
  end

  def when_i_fill_in_the_number_of_primary_placements_i_require
    fill_in "Primary", with: 2
    fill_in "Handwriting", with: 3
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
  end

  def when_i_select_english
    check "English"
  end

  def and_i_select_mathematics
    check "Mathematics"
  end

  def then_i_see_the_secondary_subject_placement_quantity_form
    expect(page).to have_title(
      "Secondary subjects: Enter the number of placements you would be willing to host - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Secondary subjects: Enter the number of placements you would be willing to host", class: "govuk-heading-l")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_field("English", type: :number)
    expect(page).to have_field("Mathematics", type: :number)
  end

  def when_i_fill_in_the_number_of_secondary_placements_i_require
    fill_in "English", with: 1
    fill_in "Mathematics", with: 4
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def when_i_click_on_cancel
    click_on "Cancel"
  end

  def then_i_see_my_responses_with_successfully_updated
    expect(page).to have_success_banner(
      "Placements added",
      "Providers can see your placements and may contact you to discuss them. You can add details to your placements such as expected date and provider.",
    )
  end

  def and_i_see_placements_i_created_for_the_subject_primary
    expect(page).to have_link(
      "Primary",
      class: "govuk-link govuk-link--no-visited-state",
      match: :prefer_exact,
      count: 2,
    )
  end

  def and_i_see_placements_i_created_for_the_subject_handwriting
    expect(page).to have_link(
      "Handwriting",
      class: "govuk-link govuk-link--no-visited-state",
      match: :prefer_exact,
      count: 3,
    )
  end

  def and_i_see_placements_i_created_for_the_subject_english
    expect(page).to have_link(
      "English",
      class: "govuk-link govuk-link--no-visited-state",
      match: :prefer_exact,
      count: 1,
    )
  end

  def and_i_see_placements_i_created_for_the_subject_mathematics
    expect(page).to have_link(
      "Mathematics",
      class: "govuk-link govuk-link--no-visited-state",
      match: :prefer_exact,
      count: 4,
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

  def when_i_select_provider_123
    check "Provider 123"
  end

  def and_i_select_provider_789
    check "Provider 789"
  end

  def when_i_click_on_the_providers_navigation
    within(primary_navigation) do
      click_on "Providers"
    end
  end

  def then_i_see_test_provider_123
    expect(page).to have_link("Test Provider 123")
  end

  def and_i_do_not_see_test_provider_456
    expect(page).not_to have_link("Test Provider 456")
  end

  def and_i_see_test_provider_789
    expect(page).to have_link("Test Provider 789")
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
    expect(page).to have_summary_list_row("Phase", "Primary and Secondary")

    expect(page).to have_h2("Primary placements")
    expect(page).to have_summary_list_row("Primary", "2")
    expect(page).to have_summary_list_row("Handwriting", "3")

    expect(page).to have_h2("Secondary placements")
    expect(page).to have_summary_list_row("English", "1")
    expect(page).to have_summary_list_row("Mathematics", "4")

    expect(page).to have_h2("Providers")
    expect(page).to have_element(
      :dt,
      text: "Test Provider 123",
      class: "govuk-summary-list__key",
    )
    expect(page).not_to have_element(
      :dt,
      text: "Test Provider 456",
      class: "govuk-summary-list__key",
    )
    expect(page).to have_element(
      :dt,
      text: "Test Provider 789",
      class: "govuk-summary-list__key",
    )
  end
end
