require "rails_helper"

RSpec.describe "School user adds their hosting interest and bulk adds placements for the secondary phase",
               service: :placements,
               type: :system do
  scenario do
    given_subjects_exist
    and_academic_years_exist
    and_i_am_signed_in

    when_i_visit_the_add_hosting_interest_page
    then_i_see_the_appetite_form

    when_i_select_actively_looking_to_host_placements
    and_i_click_on_continue
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
    then_i_see_the_school_contact_form

    when_i_fill_in_the_school_contact_details
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_publish_placements
    then_i_see_the_whats_next_page
    and_i_see_1_secondary_placement_for_english_have_been_created
    and_i_see_4_secondary_placements_for_mathematics_have_been_created
    and_the_schools_contact_has_been_updated
    and_the_schools_hosting_interest_for_the_next_year_is_updated

    when_i_click_on_edit_your_placements
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

  def when_i_visit_the_add_hosting_interest_page
    visit new_add_hosting_interest_placements_school_hosting_interests_path(@school)
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
    @school_contact = @school.school_contact.reload
    expect(@school_contact.first_name).to eq("Joe")
    expect(@school_contact.last_name).to eq("Bloggs")
    expect(@school_contact.email_address).to eq("joe_bloggs@example.com")
  end

  def and_the_schools_hosting_interest_for_the_next_year_is_updated
    hosting_interest = @school.hosting_interests.for_academic_year(@next_academic_year).last
    expect(hosting_interest.appetite).to eq("actively_looking")
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

    expect(page).to have_h2(" contact")
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
    expect(page).to have_paragraph("Providers will be able to contact you on joe_bloggs@example.com about your placement offers.")
    expect(page).to have_h2("Manage your placements", class: "govuk-heading-m")
    expect(page).to have_h2("Your placements offer", class: "govuk-heading-m")
    expect(page).not_to have_h3("Primary placements", class: "govuk-heading-s")
    expect(page).to have_h3("Secondary placements", class: "govuk-heading-s")
  end

  def and_i_see_1_secondary_placement_for_english_have_been_created
    expect(page).to have_summary_list_row("English", "1")
  end

  def and_i_see_4_secondary_placements_for_mathematics_have_been_created
    expect(page).to have_summary_list_row("Mathematics", "4")
  end

  def when_i_click_on_edit_your_placements
    click_on "Edit your placements"
  end
end
