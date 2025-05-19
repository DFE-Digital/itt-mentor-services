require "rails_helper"

RSpec.describe "School user add their hosting interest and bulk adds sends placements without knowing key stages",
               service: :placements,
               type: :system do
  scenario do
    given_key_stages_exist
    and_academic_years_exist
    and_i_am_signed_in

    when_i_visit_the_add_hosting_interest_page
    then_i_see_the_appetite_form

    when_i_select_actively_looking_to_host_placements
    and_i_click_on_continue
    then_i_see_the_phase_form

    when_i_select_send
    and_i_click_on_continue
    then_i_see_the_send_placement_quantity_form

    when_i_fill_in_the_number_of_send_placements
    and_i_click_on_continue
    then_i_see_the_key_stage_form

    when_i_select_i_dont_know
    and_i_click_on_continue
    then_i_see_the_school_contact_form

    when_i_fill_in_the_school_contact_details
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_publish_placements
    then_i_see_the_whats_next_page
    and_i_see_send_placements_have_been_created

    when_i_click_on_edit_your_placements
    then_i_see_2_send_placements
  end

  private

  def given_key_stages_exist
    @early_years = create(:key_stage, name: "Early years")
    @key_stage_1 = create(:key_stage, name: "Key stage 1")
    @key_stage_2 = create(:key_stage, name: "Key stage 2")
    @key_stage_3 = create(:key_stage, name: "Key stage 3")
    @key_stage_4 = create(:key_stage, name: "Key stage 4")
    @key_stage_5 = create(:key_stage, name: "Key stage 5")
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
      "What education phase can your placements be? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "What education phase can your placements be?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Secondary", type: :checkbox)
    expect(page).to have_field("Special educational needs and disabilities (SEND) specific", type: :checkbox)
  end

  def when_i_select_send
    check "Special educational needs and disabilities (SEND) specific"
  end

  def then_i_see_the_send_placement_quantity_form
    expect(page).to have_title(
      "How many SEND placements can you offer? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(:label, text: "How many SEND placements can you offer?", class: "govuk-label--l")
    expect(page).to have_element(:span, text: "SEND placement details", class: "govuk-caption-l")
    expect(page).to have_field("How many SEND placements can you offer?", type: :number)
  end

  def when_i_fill_in_the_number_of_send_placements
    fill_in "How many SEND placements can you offer?", with: 2
  end

  def then_i_see_the_key_stage_form
    expect(page).to have_title(
      "What SEND key stages can you offer placements in? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "What SEND key stages can you offer placements in?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_element(:span, text: "SEND placement details", class: "govuk-caption-l")
    expect(page).to have_field("Early year", type: :checkbox)
    expect(page).to have_field("Key stage 1", type: :checkbox)
    expect(page).to have_field("Key stage 2", type: :checkbox)
    expect(page).to have_field("Key stage 3", type: :checkbox)
    expect(page).to have_field("Key stage 4", type: :checkbox)
    expect(page).to have_field("Key stage 5", type: :checkbox)
    expect(page).to have_field("I don’t know", type: :checkbox)
  end

  def when_i_select_i_dont_know
    check "I don’t know"
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
    expect(page).to have_summary_list_row("Phase", "SEND")

    expect(page).to have_h2("SEND placements")
    expect(page).to have_summary_list_row("Number of SEND placements", "2")
    expect(page).to have_summary_list_row("Key stages for SEND placements", "I don’t know")

    expect(page).to have_h2("Placement contact")
    expect(page).to have_summary_list_row("First name", "Joe")
    expect(page).to have_summary_list_row("Last name", "Bloggs")
    expect(page).to have_summary_list_row("Email address", "joe_bloggs@example.com")
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
      text: "Providers will be able to contact you on joe_bloggs@example.com about your placement offers. After these discussions you can then decide whether to assign a provider to your placements.",
      class: "govuk-body",
    )
    expect(page).to have_h2("Manage your placements", class: "govuk-heading-m")
    expect(page).to have_h2("Your placements offer", class: "govuk-heading-m")
    expect(page).not_to have_h2("Primary placements", class: "govuk-heading-m")
    expect(page).not_to have_h2("Secondary placements", class: "govuk-heading-m")
    expect(page).to have_h2("SEND placements", class: "govuk-heading-m")
  end

  def and_i_see_send_placements_have_been_created
    expect(page).to have_summary_list_row("Number of SEND placements", "2")
    expect(page).to have_summary_list_row("Key stages", "I don’t know")
  end

  def when_i_click_on_edit_your_placements
    click_on "Edit your placements"
  end

  def then_i_see_2_send_placements
    expect(page).to have_link("SEND", count: 2)
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
end
