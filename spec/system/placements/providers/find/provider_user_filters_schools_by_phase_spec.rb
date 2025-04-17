require "rails_helper"

RSpec.describe "Provider user filters schools by phase", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_all_schools
    and_i_see_the_phase_filter

    when_i_select_secondary_from_the_phase_filter
    and_i_click_on_apply_filters
    then_i_see_the_secondary_school
    and_i_do_not_see_the_primary_school
    and_i_see_only_secondary_subjects_listed_in_the_subjects_filter
    and_i_see_that_the_secondary_phase_checkbox_is_selected
    and_i_see_the_secondary_filter_tag

    when_i_select_primary_from_the_phase_filter
    and_i_click_on_apply_filters
    then_i_see_all_schools
    and_i_see_all_subjects_listed_in_the_subjects_filter
    and_i_see_that_the_primary_and_secondary_phases_checkbox_are_selected
    and_i_see_the_primary_and_secondary_filter_tags

    when_i_click_on_the_secondary_phase_tag
    then_i_see_the_primary_school
    and_i_do_not_see_the_secondary_school
    and_i_do_not_see_the_secondary_phase_checkbox_selected
    and_i_do_not_see_the_secondary_filter_tag

    when_i_click_on_the_primary_phase_tag
    then_i_see_all_schools
    and_i_see_all_subjects_listed_in_the_subjects_filter
    and_i_do_not_see_any_selected_phase_checkboxes
    and_i_do_not_see_any_phase_filter_tags
  end

  private

  def given_that_schools_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")

    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")
    @secondary_school = build(:placements_school, phase: "Secondary", name: "Shelbyville High School")

    @primary_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    @springfield_primary_placement = create(:placement, school: @primary_school, subject: @primary_subject)

    @secondary_subject = build(:subject, name: "Music", subject_area: "secondary")
    @shelbyville_secondary_placement = create(:placement, school: @secondary_school, subject: @secondary_subject)
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def when_i_navigate_to_the_find_schools_page
    within ".app-primary-navigation__nav" do
      click_on "Find"
    end
  end

  def then_i_see_the_find_schools_page
    expect(page).to have_title("Find schools hosting placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Find schools hosting placements")
    expect(page).to have_h2("Filter")
  end

  def and_i_see_all_schools
    expect(page).to have_h2("Springfield Elementary")
    expect(page).to have_h2("Shelbyville High School")
  end

  def and_i_see_the_phase_filter
    expect(page).to have_element(:legend, text: "Phase", class: "govuk-fieldset__legend")
    expect(page).to have_unchecked_field("Primary")
    expect(page).to have_unchecked_field("Secondary")
  end

  def when_i_select_secondary_from_the_phase_filter
    check "Secondary"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_secondary_school
    expect(page).to have_h2("Shelbyville High School")
  end

  def and_i_do_not_see_the_primary_school
    expect(page).not_to have_h2("Springfield Elementary")
  end

  def and_i_see_only_secondary_subjects_listed_in_the_subjects_filter
    expect(page).to have_unchecked_field("Music")
    expect(page).not_to have_unchecked_field("Primary with mathematics")
  end

  def and_i_see_that_the_secondary_phase_checkbox_is_selected
    expect(page).to have_checked_field("Secondary")
  end

  def and_i_see_the_secondary_filter_tag
    expect(page).to have_filter_tag("Secondary")
  end

  def when_i_select_primary_from_the_phase_filter
    check "Primary"
  end

  def and_i_see_all_subjects_listed_in_the_subjects_filter
    expect(page).to have_unchecked_field("Primary with mathematics")
    expect(page).to have_unchecked_field("Music")
  end

  def and_i_see_that_the_primary_and_secondary_phases_checkbox_are_selected
    expect(page).to have_checked_field("Primary")
    expect(page).to have_checked_field("Secondary")
  end

  def and_i_see_the_primary_and_secondary_filter_tags
    expect(page).to have_filter_tag("Primary")
    expect(page).to have_filter_tag("Secondary")
  end

  def when_i_click_on_the_secondary_phase_tag
    within ".app-filter-tags" do
      click_on "Secondary"
    end
  end

  def then_i_see_the_primary_school
    expect(page).to have_h2("Springfield Elementary")
  end

  def and_i_do_not_see_the_secondary_school
    expect(page).not_to have_h2("Shelbyville High School")
  end

  def and_i_do_not_see_the_secondary_phase_checkbox_selected
    expect(page).to have_field("Secondary", type: "checkbox", checked: false)
    expect(page).to have_field("Primary", type: "checkbox", checked: true)
  end

  def and_i_do_not_see_the_secondary_filter_tag
    expect(page).not_to have_filter_tag("Secondary")
  end

  def when_i_click_on_the_primary_phase_tag
    within ".app-filter-tags" do
      click_on "Primary"
    end
  end

  def then_i_see_all_schools
    expect(page).to have_h2("Springfield Elementary")
    expect(page).to have_h2("Shelbyville High School")
  end

  def and_i_do_not_see_any_selected_phase_checkboxes
    expect(page).not_to have_field("Primary", type: "checkbox", checked: true)
    expect(page).not_to have_field("Secondary", type: "checkbox", checked: true)
  end

  def and_i_do_not_see_any_phase_filter_tags
    expect(page).not_to have_h3("Phase")
    expect(page).not_to have_filter_tag("Primary")
    expect(page).not_to have_filter_tag("Secondary")
  end
end
