require "rails_helper"

RSpec.describe "School user edits their hosting interest and bulk adds placements for the SEND phase",
               service: :placements,
               type: :system do
  scenario do
    given_subjects_exist
    and_academic_years_exist
    and_key_stages_exist
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

    when_i_select_send
    and_i_click_on_continue
    then_i_see_the_key_stage_selection_form

    when_i_select_key_stage_2
    and_i_select_key_stage_5
    and_i_click_on_continue
    then_i_see_the_key_stage_placement_quantity_form

    when_i_fill_in_the_number_of_send_placements_i_require
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_publish_placements
    then_i_see_the_whats_next_page
    and_i_see_a_send_placement_for_key_stage_2_has_been_created
    and_i_see_two_send_placements_for_key_stage_5_have_been_created

    when_i_click_on_edit_your_placements
    then_i_am_on_the_placements_index_page
    and_i_see_1_send_placement_for_key_stage_2
    and_i_see_2_send_placement_for_key_stage_5
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

  def and_key_stages_exist
    @early_years = create(:key_stage, name: "Early years")
    @key_stage_1 = create(:key_stage, name: "Key stage 1")
    @key_stage_2 = create(:key_stage, name: "Key stage 2")
    @key_stage_3 = create(:key_stage, name: "Key stage 3")
    @key_stage_4 = create(:key_stage, name: "Key stage 4")
    @key_stage_5 = create(:key_stage, name: "Key stage 5")
    @mixed_key_stages = create(:key_stage, name: "Mixed key stages")
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
      "Can your school offer placements for trainee teachers in the academic year #{@next_academic_year_name}? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
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
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_element(
      :legend,
      text: "What education phase can your placements be?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_hint("Select all that apply")
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Secondary", type: :checkbox)
  end

  def when_i_select_send
    check "Special educational needs and disabilities (SEND) specific"
  end

  def then_i_see_the_key_stage_selection_form
    expect(page).to have_title(
      "What key stages can you offer SEND placements in? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_span_caption("SEND placement details")
    expect(page).to have_element(
      :legend,
      text: "What key stages can you offer SEND placements in?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Early year", type: :checkbox)
    expect(page).to have_field("Key stage 1", type: :checkbox)
    expect(page).to have_field("Key stage 2", type: :checkbox)
    expect(page).to have_field("Key stage 3", type: :checkbox)
    expect(page).to have_field("Key stage 4", type: :checkbox)
    expect(page).to have_field("Key stage 5", type: :checkbox)
    expect(page).to have_field("Mixed key stages", type: :checkbox)
  end

  def when_i_select_key_stage_2
    check "Key stage 2"
  end

  def and_i_select_key_stage_5
    check "Key stage 5"
  end

  def then_i_see_the_key_stage_placement_quantity_form
    expect(page).to have_title(
      "Enter the number of SEND placements you can offer - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_span_caption("SEND placement details")
    expect(page).to have_h1("Enter the number of SEND placements you can offer", class: "govuk-heading-l")
    expect(page).to have_field("Key stage 2", type: :number)
    expect(page).to have_field("Key stage 5", type: :number)
  end

  def when_i_fill_in_the_number_of_send_placements_i_require
    fill_in "Key stage 2", with: 1
    fill_in "Key stage 5", with: 2
  end

  def then_i_see_the_school_contact_form
    expect(page).to have_title(
      "Who should providers contact? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
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

  def when_i_click_on_publish_placements
    click_on "Publish placements"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title(
      "Check your answers - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
    expect(page).to have_h1("Check your answers")

    expect(page).to have_h2("Education phase")
    expect(page).to have_summary_list_row("Phase", "SEND")

    expect(page).to have_h2("SEND placements")
    expect(page).to have_summary_list_row("Key stage 2", "1")
    expect(page).to have_summary_list_row("Key stage 5", "2")
  end

  def then_i_see_the_whats_next_page
    expect(page).to have_title(
      "What happens next? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Organisation details")
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
    expect(page).not_to have_h3("Primary placements", class: "govuk-heading-s")
    expect(page).not_to have_h3("Secondary placements", class: "govuk-heading-s")
    expect(page).to have_h3("SEND placements", class: "govuk-heading-s")
  end

  def and_i_see_a_send_placement_for_key_stage_2_has_been_created
    expect(page).to have_summary_list_row("Key stage 2", "1")
  end

  def and_i_see_two_send_placements_for_key_stage_5_have_been_created
    expect(page).to have_summary_list_row("Key stage 5", "2")
  end

  def when_i_click_on_edit_your_placements
    click_on "Edit your placements"
  end

  def when_i_am_on_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(page).to have_link("Add multiple placements")
  end
  alias_method :then_i_am_on_the_placements_index_page,
               :when_i_am_on_the_placements_index_page

  def and_i_see_1_send_placement_for_key_stage_2
    expect(page).to have_link(
      "SEND (Key stage 2)",
      class: "govuk-link govuk-link--no-visited-state",
      match: :prefer_exact,
      count: 1,
    )
  end

  def and_i_see_2_send_placement_for_key_stage_5
    expect(page).to have_link(
      "SEND (Key stage 5)",
      class: "govuk-link govuk-link--no-visited-state",
      match: :prefer_exact,
      count: 2,
    )
  end
end
