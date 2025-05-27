require "rails_helper"

RSpec.describe "School user updates their school's primary potential placement details",
               service: :placements,
               type: :system do
  scenario do
    given_academic_years_exist
    and_subjects_exist
    and_a_school_exists_with_a_hosting_interest_and_potential_placement_details
    and_i_am_signed_in
    and_i_see_the_schools_potential_placement_details
    when_i_click_on_change_year_group
    then_i_see_the_primary_year_group_selection_form
    and_year_2_is_pre_selected
    and_year_3_is_pre_selected

    when_i_unselect_year_2
    and_i_select_year_5
    and_i_click_on_continue
    then_i_see_the_primary_placement_quantity_known_page

    when_i_select_yes
    and_i_click_on_continue
    then_i_see_the_primary_placement_quantity_form
    and_the_year_3_input_is_prefilled

    when_i_fill_in_year_3_with_1
    and_i_fill_in_year_5_with_2
    and_i_click_on_continue
    then_i_see_the_secondary_subject_selection_form
    and_english_is_pre_selected
    and_science_is_pre_selected

    when_i_unselect_science
    and_i_select_mathematics
    and_i_click_on_continue
    then_i_see_the_secondary_placement_quantity_known_page

    when_i_select_yes
    and_i_click_on_continue
    then_i_see_the_secondary_subject_placement_quantity_form
    and_the_english_input_is_prefilled

    when_i_fill_in_english_with_2
    and_i_fill_in_mathematics_with_1
    and_i_click_on_continue
    then_i_see_the_provider_note_page
    and_the_provider_note_input_is_prefilled

    when_i_enter_a_new_note_for_the_provider
    and_i_click_on_continue
    then_i_see_the_confirmation_page
    and_i_see_the_education_phases_i_selected
    and_i_see_the_potential_primary_placement_details_i_entered
    and_i_see_the_potential_secondary_placement_details_i_entered
    and_i_see_the_message_to_provider_i_entered

    when_i_click_on_confirm
    then_i_see_the_whats_next_page
    and_the_schools_potential_placement_details_have_been_updated
  end

  private

  def given_academic_years_exist
    current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = current_academic_year.name
    @next_academic_year = current_academic_year.next
    @next_academic_year_name = @next_academic_year.name
  end

  def and_subjects_exist
    @primary = create(:subject, :primary, name: "Primary")

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

  def when_i_click_on_change_year_group
    click_on "Change Year group"
  end

  def then_i_see_the_phase_known_page
    expect(page).to have_title(
      "What education phase could you offer placements in? - Manage school placements - GOV.UK",
    )
    expect(page).to have_element(
      :legend,
      text: "What education phase could you offer placements in?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Secondary", type: :checkbox)
    expect(page).to have_field("I don’t know", type: :checkbox)
  end

  def and_primary_is_pre_selected
    expect(page).to have_field("Primary", type: :checkbox, checked: true)
  end

  def and_secondary_is_pre_selected
    expect(page).to have_field("Secondary", type: :checkbox, checked: true)
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_primary_year_group_selection_form
    expect(page).to have_title(
      "What year groups could you offer placements in? - Manage school placements - GOV.UK",
    )
    expect(page).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "What year groups could you offer placements in?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_element(:span, text: "Potential primary placement details", class: "govuk-caption-l")
    expect(page).to have_field("Nursery", type: :checkbox)
    expect(page).to have_field("Reception", type: :checkbox)
    expect(page).to have_field("Year 1", type: :checkbox)
    expect(page).to have_field("Year 2", type: :checkbox)
    expect(page).to have_field("Year 3", type: :checkbox)
    expect(page).to have_field("Year 4", type: :checkbox)
    expect(page).to have_field("Year 5", type: :checkbox)
    expect(page).to have_field("Year 6", type: :checkbox)
    expect(page).to have_field("Mixed year groups", type: :checkbox)
    expect(page).to have_field("I don’t know", type: :checkbox)
  end

  def and_year_2_is_pre_selected
    expect(page).to have_field("Year 2", type: :checkbox, checked: true)
  end

  def and_year_3_is_pre_selected
    expect(page).to have_field("Year 3", type: :checkbox, checked: true)
  end

  def when_i_unselect_year_2
    uncheck "Year 2"
  end

  def and_i_select_year_5
    check "Year 5"
  end

  def then_i_see_the_primary_placement_quantity_known_page
    expect(page).to have_title(
      "Do you know how many placements could you offer for each primary school year group? - Manage school placements - GOV.UK",
    )
    expect(page).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Potential primary placement details", class: "govuk-caption-l")
    expect(page).to have_element(
      :legend,
      text: "Do you know how many placements could you offer for each primary school year group?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Yes", type: :radio)
    expect(page).to have_field("No", type: :radio)
  end

  def when_i_select_yes
    choose "Yes"
  end

  def then_i_see_the_primary_placement_quantity_form
    expect(page).to have_title(
      "How many placements could you offer for each year group? - Manage school placements - GOV.UK",
    )
    expect(page).to have_current_item("Placements")
    expect(page).to have_h1("How many placements could you offer for each year group?", class: "govuk-heading-l")
    expect(page).to have_element(:span, text: "Potential primary placement details", class: "govuk-caption-l")
    expect(page).to have_field("Year 3", type: :number)
    expect(page).to have_field("Year 5", type: :number)
  end

  def and_the_year_3_input_is_prefilled
    expect(page).to have_field("Year 3", type: :number, with: 2)
  end

  def when_i_fill_in_year_3_with_1
    fill_in "Year 3", with: 1
  end

  def and_i_fill_in_year_5_with_2
    fill_in "Year 5", with: 2
  end

  def then_i_see_the_secondary_subject_selection_form
    expect(page).to have_title(
      "What subjects could you offer placements in? - Manage school placements - GOV.UK",
    )
    expect(page).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "What subjects could you offer placements in?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_element(:span, text: "Potential secondary placement details", class: "govuk-caption-l")
    expect(page).to have_field("English", type: :checkbox)
    expect(page).to have_field("Mathematics", type: :checkbox)
    expect(page).to have_field("Science", type: :checkbox)
    expect(page).to have_field("I don’t know", type: :checkbox)
  end

  def and_english_is_pre_selected
    expect(page).to have_field("English", type: :checkbox, checked: true)
  end

  def and_science_is_pre_selected
    expect(page).to have_field("Science", type: :checkbox, checked: true)
  end

  def when_i_unselect_science
    uncheck "Science"
  end

  def and_i_select_mathematics
    check "Mathematics"
  end

  def then_i_see_the_secondary_placement_quantity_known_page
    expect(page).to have_title(
      "Do you know how many secondary school placements you may be willing to offer? - Manage school placements - GOV.UK",
    )
    expect(page).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Potential secondary placement details", class: "govuk-caption-l")
    expect(page).to have_element(
      :legend,
      text: "Do you know how many secondary school placements you may be willing to offer?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Yes", type: :radio)
    expect(page).to have_field("No", type: :radio)
  end

  def then_i_see_the_secondary_subject_placement_quantity_form
    expect(page).to have_title(
      "How many placements could you offer for each subject? - Manage school placements - GOV.UK",
    )
    expect(page).to have_current_item("Placements")
    expect(page).to have_h1("How many placements could you offer for each subject?", class: "govuk-heading-l")
    expect(page).to have_element(:span, text: "Potential secondary placement details", class: "govuk-caption-l")
    expect(page).to have_field("English", type: :number)
    expect(page).to have_field("Mathematics", type: :number)
  end

  def and_the_english_input_is_prefilled
    expect(page).to have_field("English", type: :number, with: 1)
  end

  def when_i_fill_in_english_with_2
    fill_in "English", with: 2
  end

  def and_i_fill_in_mathematics_with_1
    fill_in "Mathematics", with: 1
  end

  def then_i_see_the_provider_note_page
    expect(page).to have_title(
      "Is there anything about your school you would like providers to know? (optional) - Manage school placements - GOV.UK",
    )
    expect(page).to have_element(
      :label,
      text: "Is there anything about your school you would like providers to know? (optional)",
    )
    expect(page).to have_element(
      :span,
      text: "Potential placement details",
      class: "govuk-caption-l",
    )
  end

  def and_the_provider_note_input_is_prefilled
    expect(page).to have_field(
      "Is there anything about your school you would like providers to know? (optional)",
      with: "Interested in offering placements at the provider's request",
    )
  end

  def when_i_enter_a_new_note_for_the_provider
    fill_in "Is there anything about your school you would like providers to know? (optional)",
            with: "Open to hosting placements in Maths, English and Science"
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_title(
      "Confirm and share what you may be able to offer - Manage school placements - GOV.UK",
    )
    expect(page).to have_current_item("Placements")
    expect(page).to have_h1("Confirm and share what you may be able to offer", class: "govuk-heading-l")
    expect(page).to have_element(:span, text: "Potential placement details", class: "govuk-caption-l")
    expect(page).to have_element(
      :p,
      text: "Providers will be able to see that you may be able to offer placements for trainee teachers.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "They will be able to see your potential placement details and will be able to use your email to contact you.",
      class: "govuk-body",
    )
  end

  def and_i_see_the_education_phases_i_selected
    expect(page).to have_h2("Potential education phase", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("Phase", "Primary Secondary")
  end

  def and_i_see_the_potential_primary_placement_details_i_entered
    expect(page).to have_h2("Potential primary placements", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("Year 3", "1")
    expect(page).to have_summary_list_row("Year 5", "2")
  end

  def and_i_see_the_potential_secondary_placement_details_i_entered
    expect(page).to have_h2("Potential secondary placements", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("English", "2")
    expect(page).to have_summary_list_row("Mathematics", "1")
  end

  def and_i_see_the_message_to_provider_i_entered
    expect(page).to have_h2("Additional information", class: "govuk-heading-m")
    expect(page).to have_summary_list_row(
      "Message to providers",
      "Open to hosting placements in Maths, English and Science",
    )
  end

  def when_i_click_on_confirm
    click_on "Confirm"
  end

  def then_i_see_the_whats_next_page
    expect(page).to have_panel(
      "Information added",
      "Providers can see that you may offer placements",
    )
    expect(page).to have_h1("What happens next", class: "govuk-heading-l")
    expect(page).to have_element(
      :p,
      text: "Providers who are looking for schools to work with can contact you on #{@school.school_contact_email_address}.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "Once you are sure which placements your school can offer, add your placements. Doing so will mean you will be able to assign providers to them.",
      class: "govuk-body",
    )
    expect(page).to have_link("add your placements", href: placements_school_placements_path(@school))
  end

  def and_the_schools_potential_placement_details_have_been_updated
    potential_placement_details = @school.reload.potential_placement_details

    expect(potential_placement_details["phase"]).to eq({ "phases" => %w[Primary Secondary] })
    expect(potential_placement_details["year_group_selection"]).to eq(
      { "year_groups" => %w[year_3 year_5] },
    )
    expect(potential_placement_details["year_group_placement_quantity"]).to eq(
      { "year_3" => 1, "year_5" => 2 },
    )
    expect(
      potential_placement_details.dig("secondary_subject_selection", "subject_ids").sort,
    ).to eq(
      [@english.id, @mathematics.id].sort,
    )
    expect(potential_placement_details["secondary_placement_quantity"]).to eq(
      { "english" => 2, "mathematics" => 1 },
    )
    expect(potential_placement_details["note_to_providers"]).to eq(
      { "note" => "Open to hosting placements in Maths, English and Science" },
    )
  end
end
