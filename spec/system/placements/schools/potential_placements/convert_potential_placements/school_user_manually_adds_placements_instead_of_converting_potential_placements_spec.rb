require "rails_helper"

RSpec.describe "School user manually adds placements instead of converting potential placements",
               service: :placements,
               type: :system do
  scenario do
    given_academic_years_exist
    and_subjects_exist
    and_a_school_exists_with_a_hosting_interest_and_potential_placement_details
    and_i_am_signed_in
    and_i_see_the_placements_index_page
    and_i_see_the_schools_potential_placement_details
    and_i_see_my_hosting_interest_is_may_offer_placements

    when_i_click_on_add_you_placements
    then_i_see_the_convert_current_information_page

    when_i_select_no_i_will_manually_add_the_placements_i_can_offer
    and_i_click_on_continue
    then_i_see_the_phase_form

    when_i_select_primary
    and_i_select_secondary
    and_i_click_on_continue
    then_i_see_the_primary_year_group_selection_form

    when_i_select_year_1
    and_i_click_on_continue
    then_i_see_the_primary_placement_quantity_form

    when_i_fill_in_the_number_of_primary_placements_i_require
    and_i_click_on_continue
    then_i_see_the_secondary_subject_selection_form

    when_i_select_english
    and_i_select_mathematics
    and_i_click_on_continue
    then_i_see_the_secondary_subject_placement_quantity_form

    when_i_fill_in_the_number_of_secondary_placements_i_require
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_back
    then_i_see_the_secondary_subject_placement_quantity_form

    when_i_click_on_back
    then_i_see_the_secondary_subject_selection_form

    when_i_click_on_back
    then_i_see_the_primary_placement_quantity_form

    when_i_click_on_back
    then_i_see_the_primary_year_group_selection_form

    when_i_click_on_back
    then_i_see_the_phase_form

    when_i_click_on_back
    then_i_see_the_convert_current_information_page

    when_i_select_no_i_will_manually_add_the_placements_i_can_offer
    and_i_click_on_continue
    then_i_see_the_phase_form

    when_i_select_primary
    and_i_select_secondary
    and_i_click_on_continue
    then_i_see_the_primary_year_group_selection_form

    when_i_select_year_1
    and_i_click_on_continue
    then_i_see_the_primary_placement_quantity_form

    when_i_fill_in_the_number_of_primary_placements_i_require
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
    and_i_see_2_year_1_primary_placements_have_been_created
    and_i_see_1_english_secondary_placement_has_been_created
    and_i_see_4_mathematics_secondary_placements_have_been_created
    and_the_schools_hosting_interest_for_the_next_year_is_updated

    when_i_click_on_edit_your_placements
    and_i_see_the_placements_index_page
    and_i_see_2_primary_placements_for_year_1
    and_i_see_1_secondary_placement_for_english
    and_i_see_4_secondary_placements_for_mathematics
  end

  private

  def given_academic_years_exist
    current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = current_academic_year.name
    @next_academic_year = current_academic_year.next
    @next_academic_year_name = @next_academic_year.name
  end

  def and_subjects_exist
    @primary = create(:subject, :primary, name: "Primary", code: "00")

    @english = create(:subject, :secondary, name: "English")
    @mathematics = create(:subject, :secondary, name: "Mathematics")
    @science = create(:subject, :secondary, name: "Science")
  end

  def and_a_school_exists_with_a_hosting_interest_and_potential_placement_details
    potential_placement_details = {
      "phase" => { "phases" => %w[Primary Secondary] },
      "note_to_providers" => { "note" => "Interested in offering placements at the provider's request" },
      "year_group_selection" => { "year_groups" => %w[year_2 year_3] },
      "secondary_subject_selection" => { "subject_ids" => [@english.id, @science.id] },
      "secondary_placement_quantity" => { "english" => 1, "science" => 2 },
      "year_group_placement_quantity" => { "year_2" => 1, "year_3" => 2 },
    }
    @school = create(:placements_school, potential_placement_details:)
    @hosting_interest = create(
      :hosting_interest,
      school: @school,
      academic_year: @next_academic_year,
      appetite: "interested",
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
  end

  def then_i_see_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(page).to have_current_path(placements_school_placements_path(@school))
  end
  alias_method :and_i_see_the_placements_index_page, :then_i_see_the_placements_index_page

  def and_i_see_the_schools_potential_placement_details
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(page).to have_h1("Placements you may be able to offer", class: "govuk-heading-l")
    expect(page).to have_h2("Your potential placements", class: "govuk-heading-m")

    expect(page).to have_element(:h3, text: "Education phases", class: "govuk-heading-s")
    expect(page).to have_summary_list_row("Potential phases", "Primary Secondary")

    expect(page).to have_element(:h3, text: "Potential primary placements", class: "govuk-heading-s")
    expect(page).to have_summary_list_row("Year group", "Number of placements")
    expect(page).to have_summary_list_row("Year 2", "1")
    expect(page).to have_summary_list_row("Year 3", "2")

    expect(page).to have_element(:h3, text: "Potential secondary placements", class: "govuk-heading-s")
    expect(page).to have_summary_list_row("Subject", "Number of placements")
    expect(page).to have_summary_list_row("English", "1")
    expect(page).to have_summary_list_row("Science", "2")

    expect(page).to have_element(:h3, text: "Additional information", class: "govuk-heading-s")
    expect(page).to have_summary_list_row(
      "Message to providers",
      "Interested in offering placements at the provider's request",
    )
  end

  def and_i_see_my_hosting_interest_is_may_offer_placements
    expect(page).to have_tag("May offer placements", "yellow")
    expect(page).to have_paragraph(
      "Providers can see your placement preferences and will be able to user your email to contact you.",
    )
    expect(page).to have_paragraph(
      "Once you are sure which placements your school can offer, add your placements. You can then assign your placements to providers.",
    )
  end

  def when_i_click_on_add_you_placements
    click_on "add your placements"
  end

  def then_i_see_the_convert_current_information_page
    expect(page).to have_title(
      "Would you like to convert any of your current information? - Manage school placements - GOV.UK",
    )
    expect(page).to have_span_caption("Placement details")
    expect(page).to have_element(
      :legend,
      text: "Would you like to convert any of your current information?",
      class: "govuk-fieldset__legend govuk-fieldset__legend--l",
    )
    expect(page).to have_hint("You can add or edit placements any time after publishing them.")

    expect(page).to have_field("Yes, I will select the potential placements I want to convert", type: :radio)
    expect(page).to have_field("No, I will manually add the placements I can offer", type: :radio)

    expect(page).to have_button("Continue")

    expect(page).to have_link("Cancel", href: placements_school_placements_path(@school))
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def when_i_select_no_i_will_manually_add_the_placements_i_can_offer
    choose "No, I will manually add the placements I can offer"
  end

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

  def and_i_select_secondary
    check "Secondary"
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

  def when_i_fill_in_the_number_of_primary_placements_i_require
    fill_in "Year 1", with: 2
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

  def then_i_see_the_school_contact_form
    expect(page).to have_title(
      "Who should providers contact? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Who should providers contact?")
    expect(page).to have_element(
      :p,
      text: "Choose the person best placed to organise placements for trainee teachers at your school",
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
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Who should providers contact?")
    expect(page).to have_element(
      :p,
      text: "Choose the person best placed to organise placements for trainee teachers at your school",
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
    expect(page).to have_summary_list_row("Phase", "Primary Secondary")

    expect(page).to have_h2("Primary placements")
    expect(page).to have_summary_list_row("Year 1", "2")

    expect(page).to have_h2("Secondary placements")
    expect(page).to have_summary_list_row("English", "1")
    expect(page).to have_summary_list_row("Mathematics", "4")
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
    expect(page).to have_h2("Primary placements", class: "govuk-heading-m")
    expect(page).to have_h2("Secondary placements", class: "govuk-heading-m")
  end

  def and_i_see_2_year_1_primary_placements_have_been_created
    expect(page).to have_summary_list_row("Year 1", "2")
  end

  def and_i_see_1_english_secondary_placement_has_been_created
    expect(page).to have_summary_list_row("English", "1")
  end

  def and_i_see_4_mathematics_secondary_placements_have_been_created
    expect(page).to have_summary_list_row("Mathematics", "4")
  end

  def when_i_click_on_edit_your_placements
    click_on "Edit your placements"
  end

  def and_i_see_2_primary_placements_for_year_1
    expect(page).to have_link("Primary (Year 1)", count: 2)
  end

  def and_i_see_1_secondary_placement_for_english
    expect(page).to have_link("English")
  end

  def and_i_see_4_secondary_placements_for_mathematics
    expect(page).to have_link("Mathematics", count: 4)
  end
end
