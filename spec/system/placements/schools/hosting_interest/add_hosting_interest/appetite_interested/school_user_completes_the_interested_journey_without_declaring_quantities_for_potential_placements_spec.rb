require "rails_helper"

RSpec.describe "School user completes the interested journey without declaring quantites for potential placements",
               service: :placements,
               type: :system do
  scenario do
    given_academic_years_exist
    and_subjects_exist
    and_key_stages_exist
    and_i_am_signed_in

    when_i_visit_the_add_hosting_interest_page
    then_i_see_the_appetite_form

    when_i_select_interested_in_hosting_placements
    and_i_click_on_continue
    then_i_see_the_phase_known_page

    when_i_select_primary
    and_i_select_secondary
    and_i_select_send
    and_i_click_on_continue
    then_i_see_the_primary_year_group_selection_form

    when_i_select_year_1
    and_i_click_on_continue
    then_i_see_the_primary_placement_quantity_known_page

    when_i_select_no
    and_i_click_on_continue
    then_i_see_the_secondary_subject_selection_form

    when_i_select_english
    and_i_select_mathematics
    and_i_click_on_continue
    then_i_see_the_secondary_placement_quantity_known_page

    when_i_select_no
    and_i_click_on_continue
    then_i_see_the_key_stage_selection_form

    when_i_select_key_stage_2
    and_i_select_key_stage_5
    and_i_click_on_continue
    then_i_see_the_key_stage_placement_quantity_known_page

    when_i_select_no
    and_i_click_on_continue
    then_i_see_the_provider_note_page

    when_i_enter_a_note_to_the_provider
    and_i_click_on_continue
    then_i_see_the_school_contact_form

    when_i_fill_in_the_school_contact_details
    and_i_click_on_continue
    then_i_see_the_confirmation_page
    and_i_see_the_entered_school_contact_details
    and_i_see_the_education_phases_i_selected
    and_i_see_the_potential_primary_placement_details_with_no_quantities
    and_i_see_the_potential_secondary_placement_details_with_no_quantities
    and_i_see_the_potential_send_placement_details_with_no_quantities
    and_i_see_the_message_to_provider_i_entered

    when_i_click_on_confirm
    then_i_see_the_whats_next_page
    and_the_schools_contact_has_been_updated
    and_the_schools_hosting_interest_for_the_next_year_is_updated
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

  def and_key_stages_exist
    @early_years = create(:key_stage, name: "Early years")
    @key_stage_1 = create(:key_stage, name: "Key stage 1")
    @key_stage_2 = create(:key_stage, name: "Key stage 2")
    @key_stage_3 = create(:key_stage, name: "Key stage 3")
    @key_stage_4 = create(:key_stage, name: "Key stage 4")
    @key_stage_5 = create(:key_stage, name: "Key stage 5")
    @mixed_key_stages = create(:key_stage, name: "Mixed key stages")
  end

  def and_i_am_signed_in
    @school = create(:placements_school, with_school_contact: false)
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

  def when_i_select_interested_in_hosting_placements
    choose "Maybe - I’m not sure yet"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end

  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_confirmation_page
    expect(page).to have_title(
      "Confirm and share what you may be able to offer - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
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

  def when_i_fill_in_the_school_contact_details
    fill_in "First name", with: "Joe"
    fill_in "Last name", with: "Bloggs"
    fill_in "Email address", with: "joe_bloggs@example.com"
  end

  def and_the_schools_contact_has_been_updated
    school_contact = @school.school_contact
    expect(school_contact.first_name).to eq("Joe")
    expect(school_contact.last_name).to eq("Bloggs")
    expect(school_contact.email_address).to eq("joe_bloggs@example.com")
  end

  def and_the_schools_hosting_interest_for_the_next_year_is_updated
    hosting_interest = @school.hosting_interests.for_academic_year(@next_academic_year).last
    expect(hosting_interest.appetite).to eq("interested")
  end

  def then_i_see_the_whats_next_page
    expect(page).to have_panel(
      "Information added",
      "Providers can see that you may offer placements",
    )
    expect(page).to have_h1("What happens next", class: "govuk-heading-l")
    expect(page).to have_element(
      :p,
      text: "Providers who are looking for schools to work with can contact you on joe_bloggs@example.com.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "Once you are sure which placements your school can offer, add your placements. Doing so will mean you will be able to assign providers to them.",
      class: "govuk-body",
    )
    expect(page).to have_link("add your placements", href: placements_school_placements_path(@school))
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
    expect(page).to have_hint(
      "Select all that apply. Sharing information on what you may be able to offer helps providers know whether to contact you." \
        " It is not a commitment to take a trainee teacher.",
    )
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Secondary", type: :checkbox)
    expect(page).to have_field("I don’t know", type: :checkbox)
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

  def when_i_enter_a_note_to_the_provider
    fill_in "Is there anything about your school you would like providers to know? (optional)", with:
      "We are open to hosting additional placements at the provider's request."
  end

  def and_i_see_the_entered_school_contact_details
    expect(page).to have_h2("Your information", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
  end

  def and_i_see_the_education_phases_i_selected
    expect(page).to have_h2("Potential education phase", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("Phase", "Primary Secondary")
  end

  def and_i_see_the_message_to_provider_i_entered
    expect(page).to have_h2("Additional information", class: "govuk-heading-m")
    expect(page).to have_summary_list_row(
      "Message to providers",
      "We are open to hosting additional placements at the provider's request.",
    )
  end

  def when_i_click_on_confirm
    click_on "Confirm"
  end

  def and_the_schools_potential_placement_details_have_been_updated
    potential_placement_details = @school.reload.potential_placement_details

    expect(potential_placement_details["phase"]).to eq({ "phases" => %w[Primary Secondary SEND] })
    expect(potential_placement_details["year_group_selection"]).to eq(
      { "year_groups" => %w[year_1] },
    )
    expect(potential_placement_details["year_group_placement_quantity"]).to be_nil
    expect(
      potential_placement_details.dig("secondary_subject_selection", "subject_ids").sort,
    ).to eq(
      [@english.id, @mathematics.id].sort,
    )
    expect(potential_placement_details["secondary_placement_quantity"]).to be_nil
    expect(
      potential_placement_details.dig("key_stage_selection", "key_stage_ids").sort,
    ).to eq(
      [@key_stage_2.id, @key_stage_5.id].sort,
    )
    expect(potential_placement_details["key_stage_placement_quantity"]).to be_nil
    expect(potential_placement_details["note_to_providers"]).to eq(
      { "note" => "We are open to hosting additional placements at the provider's request." },
    )
  end

  def when_i_select_primary
    check "Primary"
  end

  def and_i_select_secondary
    check "Secondary"
  end

  def and_i_select_send
    check "Special educational needs and disabilities (SEND) specific"
  end

  def then_i_see_the_primary_year_group_selection_form
    expect(page).to have_title(
      "What year groups could you offer placements in? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
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

  def when_i_select_year_1
    check "Year 1"
  end

  def then_i_see_the_primary_placement_quantity_known_page
    expect(page).to have_title(
      "Do you know how many placements could you offer for each primary school year group? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Potential primary placement details", class: "govuk-caption-l")
    expect(page).to have_element(
      :legend,
      text: "Do you know how many placements could you offer for each primary school year group?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Yes", type: :radio)
    expect(page).to have_field("No", type: :radio)
  end

  def when_i_select_no
    choose "No"
  end

  def then_i_see_the_secondary_subject_selection_form
    expect(page).to have_title(
      "What subjects could you offer placements in? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
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

  def when_i_select_english
    check "English"
  end

  def and_i_select_mathematics
    check "Mathematics"
  end

  def then_i_see_the_secondary_placement_quantity_known_page
    expect(page).to have_title(
      "Do you know how many secondary school placements you may be willing to offer? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:span, text: "Potential secondary placement details", class: "govuk-caption-l")
    expect(page).to have_element(
      :legend,
      text: "Do you know how many secondary school placements you may be willing to offer?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Yes", type: :radio)
    expect(page).to have_field("No", type: :radio)
  end

  def and_i_see_the_potential_primary_placement_details_with_no_quantities
    expect(page).to have_h2("Potential primary placements", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("Year 1", "Not entered")
  end

  def and_i_see_the_potential_secondary_placement_details_with_no_quantities
    expect(page).to have_h2("Potential secondary placements", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("English", "Not entered")
    expect(page).to have_summary_list_row("Mathematics", "Not entered")
  end

  def and_i_see_the_potential_send_placement_details_with_no_quantities
    expect(page).to have_h2("Potential SEND placements", class: "govuk-heading-m")
    expect(page).to have_summary_list_row("Key stage 2", "Not entered")
    expect(page).to have_summary_list_row("Key stage 5", "Not entered")
  end

  def then_i_see_the_key_stage_selection_form
    expect(page).to have_title(
      "What key stages could you offer placements in? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_span_caption("Potential SEND placement details")
    expect(page).to have_element(
      :legend,
      text: "What key stages could you offer placements in?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Early year", type: :checkbox)
    expect(page).to have_field("Key stage 1", type: :checkbox)
    expect(page).to have_field("Key stage 2", type: :checkbox)
    expect(page).to have_field("Key stage 3", type: :checkbox)
    expect(page).to have_field("Key stage 4", type: :checkbox)
    expect(page).to have_field("Key stage 5", type: :checkbox)
    expect(page).to have_field("Mixed key stages", type: :checkbox)
    expect(page).to have_field("I don’t know", type: :checkbox)
  end

  def when_i_select_key_stage_2
    check "Key stage 2"
  end

  def and_i_select_key_stage_5
    check "Key stage 5"
  end

  def then_i_see_the_key_stage_placement_quantity_known_page
    expect(page).to have_title(
      "Do you know how many placement you could offer each SEND key stage? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_span_caption("Potential SEND placement details")
    expect(page).to have_element(
      :legend,
      text: "Do you know how many placement you could offer each SEND key stage?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Yes", type: :radio)
    expect(page).to have_field("No", type: :radio)
  end
end
