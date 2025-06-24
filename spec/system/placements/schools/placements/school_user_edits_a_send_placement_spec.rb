require "rails_helper"

RSpec.describe "Primary school user edits a placement", service: :placements, type: :system do
  scenario do
    given_key_stages_exists
    and_a_placement_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_my_placement

    when_i_click_on_my_placement
    then_i_see_the_placement_details_page

    when_i_click_on_change_key_stage
    then_i_see_the_select_a_key_stage_page
    and_i_see_the_key_stage_options

    when_i_select_key_stage_5
    and_i_click_on_continue
    then_i_see_the_placement_details_page_with_my_updated_key_stage
    and_i_see_a_key_stage_updated_success_message
  end

  private

  def given_key_stages_exists
    @early_years = create(:key_stage, name: "Early years")
    @key_stage_1 = create(:key_stage, name: "Key stage 1")
    @key_stage_2 = create(:key_stage, name: "Key stage 2")
    @key_stage_3 = create(:key_stage, name: "Key stage 3")
    @key_stage_4 = create(:key_stage, name: "Key stage 4")
    @key_stage_5 = create(:key_stage, name: "Key stage 5")
    @mixed_key_stages = create(:key_stage, name: "Mixed key stages")
  end

  def and_a_placement_exist
    @school = create(:placements_school, :primary)

    @next_academic_year = Placements::AcademicYear.current.next
    @next_academic_year_name = @next_academic_year.name

    @send_placement = create(
      :placement,
      :send,
      key_stage: @key_stage_1,
      school: @school,
      academic_year: @next_academic_year,
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_am_on_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(page).to have_element(:a, text: "Add placement", class: "govuk-button")
  end

  def then_i_see_my_placement
    expect(page).to have_table_row({
      "Placement" => "SEND (Key stage 1)",
      "Mentor" => "Mentor not assigned",
      "Expected date" => "Any time in the academic year",
      "Provider" => "Provider not assigned",
    })
  end

  def when_i_click_on_my_placement
    click_on "SEND (Key stage 1)"
  end

  def then_i_see_the_placement_details_page
    expect(page).to have_title("SEND (Key stage 1) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Available", "green")
    expect(page).to have_summary_list_row("Key stage", "Key stage 1")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Any time in the academic year")
    expect(page).to have_summary_list_row("Mentor", "Add a mentor")
    expect(page).to have_summary_list_row("Provider", "Assign a provider")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
    expect(page).to have_link("Delete placement", href: "/schools/#{@school.id}/placements/#{@send_placement.id}/remove")
  end

  def when_i_click_on_change_key_stage
    click_on "Change Key stage"
  end

  def then_i_see_the_select_a_key_stage_page
    expect(page).to have_title("Select a key stage - Placement details - Manage school placements - GOV.UK")
    expect(page).to have_element(
      :legend,
      text: "Select a key stage",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_link("Cancel", href: "/schools/#{@school.id}/placements/#{@send_placement.id}")
  end

  def and_i_see_the_key_stage_options
    expect(page).to have_field("Early years", type: :radio)
    expect(page).to have_field("Key stage 1", type: :radio, checked: true)
    expect(page).to have_field("Key stage 2", type: :radio)
    expect(page).to have_field("Key stage 3", type: :radio)
    expect(page).to have_field("Key stage 4", type: :radio)
    expect(page).to have_field("Key stage 5", type: :radio)
    expect(page).to have_field("Mixed key stages", type: :radio)
  end

  def when_i_select_key_stage_5
    choose "Key stage 5"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_placement_details_page_with_my_updated_key_stage
    expect(page).to have_title("SEND (Key stage 5) - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_tag("Available", "green")
    expect(page).to have_summary_list_row("Key stage", "Key stage 5")
    expect(page).to have_summary_list_row("Academic year", "Next year (#{@next_academic_year_name})")
    expect(page).to have_summary_list_row("Expected date", "Any time in the academic year")
    expect(page).to have_summary_list_row("Mentor", "Add a mentor")
    expect(page).to have_summary_list_row("Provider", "Assign a provider")
    expect(page).to have_element(:div, text: "You can preview this placement as it appears to providers.", class: "govuk-inset-text")
    expect(page).to have_link("Delete placement", href: "/schools/#{@school.id}/placements/#{@send_placement.id}/remove")
  end

  def and_i_see_a_key_stage_updated_success_message
    expect(page).to have_success_banner("Key stage updated")
  end
end
