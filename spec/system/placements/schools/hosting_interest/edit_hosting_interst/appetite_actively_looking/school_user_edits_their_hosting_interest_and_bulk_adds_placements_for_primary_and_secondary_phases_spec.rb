require "rails_helper"

RSpec.describe "School user edits their hosting interest and bulk adds placements for primary and secondary phases",
               service: :placements,
               type: :system do
  scenario do
    given_subjects_exist
    and_test_providers_exist
    and_academic_years_exist
    and_a_school_exists_with_a_hosting_interest
    and_i_am_signed_in

    when_i_navigate_to_organisation_details
    then_i_see_the_organisation_details_page
    and_i_see_the_hosting_interest_for_the_next_academic_year

    when_i_click_on_change_hosting_status
    then_i_see_the_appetite_form

    when_i_select_actively_looking_to_host_placements
    and_i_click_on_continue
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

    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_back
    then_i_see_the_provider_select_form

    when_i_click_on_back
    then_i_see_the_secondary_subject_placement_quantity_form

    when_i_click_on_back
    then_i_see_the_secondary_subject_selection_form

    when_i_click_on_back
    then_i_see_the_primary_subject_placement_quantity_form

    when_i_click_on_back
    then_i_see_the_primary_subject_selection_form

    when_i_click_on_back
    then_i_see_the_phase_form

    when_i_click_on_back
    then_i_see_the_appetite_form

    when_i_select_actively_looking_to_host_placements
    and_i_click_on_continue
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

    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_save_and_continue
    then_i_see_my_responses_with_successfully_updated
    and_the_schools_hosting_interest_for_the_next_year_is_updated
    and_i_see_placements_i_created_for_the_subject_primary
    and_i_see_placements_i_created_for_the_subject_handwriting
    and_i_see_placements_i_created_for_the_subject_english
    and_i_see_placements_i_created_for_the_subject_mathematics
  end

  private

  def given_subjects_exist
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

  def and_a_school_exists_with_a_hosting_interest
    @school = create(:placements_school)
    @hosting_interest = create(
      :hosting_interest,
      school: @school,
      academic_year: @next_academic_year,
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_navigate_to_organisation_details
    within(primary_navigation) do
      click_on "Organisation details"
    end
  end

  def then_i_see_the_organisation_details_page
    expect(page).to have_current_item("Organisation details")
    expect(page).to have_title(
      "Organisation details - Manage school placements - GOV.UK",
    )
    expect(page).to have_h1(@school.name)
    expect(page).to have_h2("Hosting status")
    expect(page).to have_element(
      :p,
      text: "This status indicates to providers whether you intend to host placements.",
      class: "govuk-body",
    )
  end

  def and_i_see_the_hosting_interest_for_the_next_academic_year
    expect(page).to have_summary_list_row(
      "Status", "Open to hosting"
    )
  end

  def when_i_click_on_change_hosting_status
    click_on "Change Hosting status"
  end

  def then_i_see_the_appetite_form
    expect(page).to have_title(
      "Can your school offer placements for trainee teachers in this academic year (#{@next_academic_year_name})? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_element(
      :legend,
      text: "Can your school offer placements for trainee teachers in this academic year (#{@next_academic_year_name})?",
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
      "What phase of education will your placements be? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
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

  def then_i_see_the_subjects_known_form
    expect(page).to have_title(
      "Do you know which subjects you would like to host? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_element(
      :legend,
      text: "Do you know which subjects you would like to host?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Yes", type: :radio)
    expect(page).to have_field("No", type: :radio)
  end

  def when_i_select_yes
    choose "Yes"
  end

  def then_i_see_the_primary_subject_selection_form
    expect(page).to have_title(
      "Select primary school subjects - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
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
    expect(primary_navigation).to have_current_item("Organisation details")
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
    expect(primary_navigation).to have_current_item("Organisation details")
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
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_h1("Secondary subjects: Enter the number of placements you would be willing to host", class: "govuk-heading-l")
    expect(page).to have_element(:span, text: "Placement details", class: "govuk-caption-l")
    expect(page).to have_field("English", type: :number)
    expect(page).to have_field("Mathematics", type: :number)
  end

  def when_i_fill_in_the_number_of_secondary_placements_i_require
    fill_in "English", with: 1
    fill_in "Mathematics", with: 4
  end

  def then_i_see_the_school_contact_form
    expect(page).to have_title(
      "Who should providers contact? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_h1("Who should providers contact?")
    expect(page).to have_element(
      :p,
      text: "Choose the person best placed to organise ITT placements at your school. "\
        "This information will be shown on your profile.",
      class: "govuk-body",
    )

    expect(page).to have_field("First name")
    expect(page).to have_field("Last name")
    expect(page).to have_field("Email address")
  end

  def then_i_see_the_school_contact_form_prefilled_with_my_inputs
    expect(page).to have_title(
      "Who should providers contact? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_h1("Who should providers contact?")
    expect(page).to have_element(
      :p,
      text: "Choose the person best placed to organise ITT placements at your school. "\
        "This information will be shown on your profile.",
      class: "govuk-body",
    )

    @school_contact = @school.school_contact
    expect(page).to have_field("First name", with: "Joe")
    expect(page).to have_field("Last name", with: "Bloggs")
    expect(page).to have_field("Email address", with: "joe_bloggs@example.com")
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def when_i_click_on_cancel
    click_on "Cancel"
  end

  def when_i_fill_in_the_school_contact_details
    fill_in "First name", with: "Joe"
    fill_in "Last name", with: "Bloggs"
    fill_in "Email address", with: "joe_bloggs@example.com"
  end

  def then_i_see_my_responses_with_successfully_updated
    expect(page).to have_success_banner(
      "Placement information uploaded",
      "Providers can see your placement preferences and may contact you to discuss them. You can add details to your placements such as expected date and provider.",
    )
  end

  def and_the_schools_contact_has_been_updated
    @school_contact.reload
    expect(@school_contact.first_name).to eq("Joe")
    expect(@school_contact.last_name).to eq("Bloggs")
    expect(@school_contact.email_address).to eq("joe_bloggs@example.com")
  end

  def and_the_schools_hosting_interest_for_the_next_year_is_updated
    hosting_interest = @school.hosting_interests.for_academic_year(@next_academic_year).last
    expect(hosting_interest.appetite).to eq("actively_looking")
  end

  def when_i_click_on_the_academic_year_tab
    click_on "Next year (#{@next_academic_year.name})"
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
    expect(primary_navigation).to have_current_item("Organisation details")
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
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_h1("Check your answers")

    expect(page).to have_h2("Education phase")
    expect(page).to have_summary_list_row("Phase", "Primary and Secondary")

    expect(page).to have_h2("Primary placements")
    expect(page).to have_summary_list_row("Primary", "2")
    expect(page).to have_summary_list_row("Handwriting", "3")

    expect(page).to have_h2("Secondary placements")
    expect(page).to have_summary_list_row("English", "1")
    expect(page).to have_summary_list_row("Mathematics", "4")

    expect(page).not_to have_h2("Providers")
  end
end
