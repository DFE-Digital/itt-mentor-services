require "rails_helper"

RSpec.describe "School user bulk adds placements for the send phase",
               service: :placements,
               type: :system do
  scenario do
    given_key_stages_exist
    and_academic_years_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    and_i_click_on_add_multiple_placements
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

  def given_key_stages_exist
    @early_years = create(:key_stage, name: "Early years")
    @key_stage_1 = create(:key_stage, name: "Key stage 1")
    @key_stage_2 = create(:key_stage, name: "Key stage 2")
    @key_stage_3 = create(:key_stage, name: "Key stage 3")
    @key_stage_4 = create(:key_stage, name: "Key stage 4")
    @key_stage_5 = create(:key_stage, name: "Key stage 5")
    @mixed_key_stages = create(:key_stage, name: "Mixed key stages")
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
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Secondary", type: :checkbox)
    expect(page).to have_field("Special educational needs and disabilities (SEND) specific", type: :checkbox)
  end

  def when_i_select_send
    check "Special educational needs and disabilities (SEND) specific"
  end

  def then_i_see_the_key_stage_selection_form
    expect(page).to have_title(
      "What SEND key stages can you offer placements in? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_span_caption("SEND placement details")
    expect(page).to have_element(
      :legend,
      text: "What SEND key stages can you offer placements in?",
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
      "How many SEND placements can you offer? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_span_caption("SEND placement details")
    expect(page).to have_h1("How many SEND placements can you offer?", class: "govuk-heading-l")
    expect(page).to have_field("Key stage 2", type: :number)
    expect(page).to have_field("Key stage 5", type: :number)
  end

  def when_i_fill_in_the_number_of_send_placements_i_require
    fill_in "Key stage 2", with: 1
    fill_in "Key stage 5", with: 2
  end

  def then_i_see_my_responses_were_successfully_updated
    expect(page).to have_success_banner(
      "Placements added",
      "Providers can see your placements and may contact you to discuss them. You can add details to your placements such as expected date and provider.",
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
    expect(page).to have_summary_list_row("Phase", "SEND")

    expect(page).to have_h2("SEND placements")
    expect(page).to have_summary_list_row("Key stage 2", "1")
    expect(page).to have_summary_list_row("Key stage 5", "2")
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
    expect(page).not_to have_h3("Primary placements", class: "govuk-heading-s")
    expect(page).not_to have_h3("Secondary placements", class: "govuk-heading-s")
    expect(page).to have_h3("SEND placements", class: "govuk-heading-s")
  end

  def when_i_click_on_edit_your_placements
    click_on "Edit your placements"
  end

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

  def and_i_see_a_send_placement_for_key_stage_2_has_been_created
    expect(page).to have_summary_list_row("Key stage 2", "1")
  end

  def and_i_see_two_send_placements_for_key_stage_5_have_been_created
    expect(page).to have_summary_list_row("Key stage 5", "2")
  end
end
