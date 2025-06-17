require "rails_helper"

RSpec.describe "School user does not enter a key stage quantity",
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
    then_i_see_the_key_stage_selection_form

    when_i_select_key_stage_2
    and_i_select_key_stage_5
    and_i_click_on_continue
    then_i_see_the_key_stage_placement_quantity_form

    when_i_click_on_continue
    then_i_see_a_validation_error_for_not_entering_a_quantity_for_key_stage_2
    and_i_see_a_validation_error_for_not_entering_a_quantity_for_key_stage_5
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

  def then_i_see_a_validation_error_for_not_entering_a_quantity_for_key_stage_2
    expect(page).to have_validation_error(
      "Key stage 2 can't be blank",
    )
  end

  def and_i_see_a_validation_error_for_not_entering_a_quantity_for_key_stage_5
    expect(page).to have_validation_error(
      "Key stage 5 can't be blank",
    )
  end
end
