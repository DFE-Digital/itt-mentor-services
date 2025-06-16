require "rails_helper"

RSpec.describe "School user adds their hosting interest and bulk adds placements for a subject with child subjects",
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
    then_i_see_the_check_your_answers_page

    when_i_click_on_publish_placements
    then_i_see_the_whats_next_page
    and_i_see_2_secondary_placement_for_modern_languages_has_been_created

    when_i_click_on_edit_your_placements
    then_i_am_on_the_placements_index_page
    and_i_see_1_secondary_placement_for_modern_languages_french
    and_i_see_1_secondary_placement_for_modern_languages_french_and_russian
  end

  private

  def given_subjects_exist
    @english = create(:subject, :secondary, name: "English")
    @mathematics = create(:subject, :secondary, name: "Mathematics")
    @science = create(:subject, :secondary, name: "Science")
    @modern_languages = create(:subject, :secondary, name: "Modern Languages")
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
    expect(page).to have_field("Modern Languages", type: :checkbox)
  end

  def when_i_select_modern_languages
    check "Modern Languages"
  end

  def then_i_see_the_secondary_subject_placement_quantity_form
    expect(page).to have_title(
      "How many placements can you offer for each subject? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("How many placements can you offer for each subject?", class: "govuk-heading-l")
    expect(page).to have_element(:span, text: "Secondary placement details", class: "govuk-caption-l")
    expect(page).to have_field("Modern Languages", type: :number)
  end

  def when_i_fill_in_the_number_of_secondary_placements_i_require
    fill_in "Modern Languages", with: 2
  end

  def then_i_see_the_subject_selection_for_modern_languages_form
    expect(page).to have_title(
      "What languages are taught on your Modern Languages placement offers? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1(
      "What languages are taught on your Modern Languages placement offers?",
      class: "govuk-heading-l",
    )
    expect(page).to have_element(:span, text: "Secondary placement details", class: "govuk-caption-l")
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

  def and_i_see_1_secondary_placement_for_modern_languages_french
    expect(page).to have_link(
      "French",
      class: "govuk-link govuk-link--no-visited-state",
      match: :prefer_exact,
      count: 1,
    )
  end

  def and_i_see_1_secondary_placement_for_modern_languages_french_and_russian
    expect(page).to have_link(
      "Russian and Spanish",
      class: "govuk-link govuk-link--no-visited-state",
      match: :prefer_exact,
      count: 1,
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
    expect(page).to have_summary_list_row("Modern Languages", "2")
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
    expect(page).to have_element(
      :p,
      text: "Providers will be able to contact you on #{@school.school_contact_email_address} about your placement offers. After these discussions you can then decide whether to assign a provider to your placements.",
      class: "govuk-body",
    )
    expect(page).to have_h2("Manage your placements", class: "govuk-heading-m")
    expect(page).to have_h2("Your placements offer", class: "govuk-heading-m")
    expect(page).not_to have_h2("Primary placements", class: "govuk-heading-m")
    expect(page).to have_h2("Secondary placements", class: "govuk-heading-m")
  end

  def when_i_click_on_edit_your_placements
    click_on "Edit your placements"
  end

  def and_i_see_2_secondary_placement_for_modern_languages_has_been_created
    expect(page).to have_summary_list_row("Modern Languages", "2")
  end
end
