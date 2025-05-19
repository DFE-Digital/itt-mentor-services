require "rails_helper"

RSpec.describe "School user bulk adds send placements",
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
    then_i_see_the_send_placement_quantity_form

    when_i_fill_in_the_number_of_send_placements
    and_i_click_on_continue
    then_i_see_the_key_stage_form

    when_i_select_key_stage_2
    and_i_select_key_stage_5
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_save_and_continue
    then_i_see_my_responses_were_successfully_updated
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

  def when_i_select_key_stage_2
    check "Key stage 2"
  end

  def and_i_select_key_stage_5
    check "Key stage 5"
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
    expect(page).to have_summary_list_row("Key stages for SEND placements", "Key stage 2 Key stage 5")
  end

  def then_i_see_2_send_placements
    expect(page).to have_link("SEND (Key stage 2, Key stage 5)", count: 2)
  end

  def when_i_click_save_and_continue
    click_on "Save and continue"
  end

  def then_i_see_my_responses_were_successfully_updated
    expect(page).to have_success_banner(
      "Placements added",
      "Providers can see your placements and may contact you to discuss them. You can add details to your placements such as expected date and provider.",
    )
  end
end
