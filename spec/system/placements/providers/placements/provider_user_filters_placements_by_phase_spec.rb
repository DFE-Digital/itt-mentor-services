require "rails_helper"

RSpec.describe "Provider user filters placements by phase", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_navigate_to_the_placements_index_page
    then_i_am_on_the_placements_index_page
    and_i_see_all_placements
    and_i_see_the_phase_filter

    when_i_select_secondary_from_the_phase_filter
    and_i_click_on_apply_filters
    then_i_see_the_secondary_placements
    and_i_do_not_see_the_primary_placement
    and_i_no_longer_see_the_primary_year_group_filter
    and_i_see_only_secondary_subjects_listed_in_the_subjects_filter
    and_i_see_that_springfield_elementary_is_no_longer_listed_in_the_schools_filter
    and_i_see_that_ogdenville_observatoire_is_still_listed_in_the_schools_filter
    and_i_see_that_the_secondary_phase_checkbox_is_selected
    and_i_see_the_secondary_filter_tag

    when_i_select_primary_from_the_phase_filter
    and_i_click_on_apply_filters
    then_i_see_all_placements
    and_i_see_all_subjects_listed_in_the_subjects_filter
    and_i_see_all_schools_listed_in_the_schools_filter
    and_i_see_that_the_primary_and_secondary_phases_checkbox_are_selected
    and_i_see_the_primary_and_secondary_filter_tags

    when_i_click_on_the_secondary_phase_tag
    then_i_see_the_primary_placement
    and_i_do_not_see_the_secondary_placements
    and_i_do_not_see_the_secondary_phase_checkbox_selected
    and_i_do_not_see_the_secondary_filter_tag

    when_i_click_on_the_primary_phase_tag
    then_i_see_all_placements
    and_i_see_all_schools_listed_in_the_schools_filter
    and_i_see_all_subjects_listed_in_the_subjects_filter
    and_i_do_not_see_any_selected_phase_checkboxes
    and_i_do_not_see_any_phase_filter_tags
  end

  private

  def given_that_placements_exist
    academic_year = Placements::AcademicYear.current.next
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")
    @secondary_school = build(:placements_school, phase: "Secondary", name: "Shelbyville High School")
    @all_through_school = build(:placements_school, phase: "All-through", name: "Ogdenville Observatoire")

    @primary_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    @springfield_primary_placement = create(:placement, school: @primary_school, subject: @primary_subject, provider: @provider, academic_year:)

    @secondary_subject = build(:subject, name: "Music", subject_area: "secondary")
    @shelbyville_secondary_placement = create(:placement, school: @secondary_school, subject: @secondary_subject, provider: @provider, academic_year:)
    @ogdenville_secondary_placement = create(:placement, school: @all_through_school, subject: @secondary_subject, provider: @provider, academic_year:)
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def when_i_navigate_to_the_placements_index_page
    within primary_navigation do
      click_on "My placements"
    end
  end

  def then_i_am_on_the_placements_index_page
    expect(page).to have_title("My placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("My placements")
    expect(page).to have_h1("My placements")
    expect(page).to have_h2("Filter")
  end

  def and_i_see_all_placements
    expect(page).to have_table_row({
      "Subject" => "Music",
      "Expected date" => "Any time in the academic year",
      "School" => "Ogdenville Observatoire",
    })

    expect(page).to have_table_row({
      "Subject" => "Music",
      "Expected date" => "Any time in the academic year",
      "School" => "Shelbyville High School",
    })

    expect(page).to have_table_row({
      "Subject" => "Primary with mathematics",
      "Expected date" => "Any time in the academic year",
      "School" => "Springfield Elementary",
    })
  end
  alias_method :then_i_see_all_placements, :and_i_see_all_placements

  def and_i_see_the_phase_filter
    expect(page).to have_element(:legend, text: "Phase", class: "govuk-fieldset__legend")
    expect(page).to have_field("Primary", type: "checkbox", checked: false)
    expect(page).to have_field("Secondary", type: "checkbox", checked: false)
  end

  def when_i_select_secondary_from_the_phase_filter
    check "Secondary"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_secondary_placements
    expect(page).to have_table_row({
      "Subject" => "Music",
      "Expected date" => "Any time in the academic year",
      "School" => "Ogdenville Observatoire",
    })

    expect(page).to have_table_row({
      "Subject" => "Music",
      "Expected date" => "Any time in the academic year",
      "School" => "Shelbyville High School",
    })
  end

  def and_i_do_not_see_the_primary_placement
    expect(page).not_to have_table_row({
      "Subject" => "Primary with mathematics",
      "Expected date" => "Any time in the academic year",
      "School" => "Springfield Elementary",
    })
  end

  def and_i_no_longer_see_the_primary_year_group_filter
    expect(page).not_to have_element(:legend, text: "Primary year group", class: "govuk-fieldset__legend")
    expect(page).not_to have_field("Nursery", type: "checkbox")
  end

  def and_i_see_only_secondary_subjects_listed_in_the_subjects_filter
    expect(page).to have_element(:legend, text: "Subject", class: "govuk-fieldset__legend")
    expect(page).to have_field("Music", type: "checkbox", checked: false)

    expect(page).not_to have_field("Primary with mathematics", type: "checkbox", checked: false)
  end

  def and_i_see_that_springfield_elementary_is_no_longer_listed_in_the_schools_filter
    expect(page).to have_element(:legend, text: "School", class: "govuk-fieldset__legend")
    expect(page).not_to have_field("Springfield Elementary", type: "checkbox", checked: false)
  end

  def and_i_see_that_ogdenville_observatoire_is_still_listed_in_the_schools_filter
    expect(page).to have_field("Ogdenville Observatoire", type: "checkbox", checked: false)
  end

  def and_i_see_that_the_secondary_phase_checkbox_is_selected
    expect(page).to have_field("Secondary", type: "checkbox", checked: true)
  end

  def and_i_see_the_secondary_filter_tag
    expect(page).to have_h3("Phase")
    expect(page).to have_filter_tag("Secondary")
    expect(page).not_to have_filter_tag("Primary")
  end

  def when_i_select_primary_from_the_phase_filter
    check "Primary"
  end

  def and_i_see_all_subjects_listed_in_the_subjects_filter
    expect(page).to have_field("Music", type: "checkbox", checked: false)
    expect(page).to have_field("Primary with mathematics", type: "checkbox", checked: false)
  end

  def and_i_see_all_schools_listed_in_the_schools_filter
    expect(page).to have_field("Ogdenville Observatoire", type: "checkbox", checked: false)
    expect(page).to have_field("Shelbyville High School", type: "checkbox", checked: false)
    expect(page).to have_field("Springfield Elementary", type: "checkbox", checked: false)
  end

  def and_i_see_that_the_primary_and_secondary_phases_checkbox_are_selected
    expect(page).to have_field("Primary", type: "checkbox", checked: true)
    expect(page).to have_field("Secondary", type: "checkbox", checked: true)
  end

  def and_i_see_the_primary_and_secondary_filter_tags
    expect(page).to have_h3("Phase")
    expect(page).to have_filter_tag("Secondary")
    expect(page).to have_filter_tag("Primary")
  end

  def when_i_click_on_the_secondary_phase_tag
    within ".app-filter-tags" do
      click_on "Secondary"
    end
  end

  def then_i_see_the_primary_placement
    expect(page).to have_table_row({
      "Subject" => "Primary with mathematics",
      "Expected date" => "Any time in the academic year",
      "School" => "Springfield Elementary",
    })
  end

  def and_i_do_not_see_the_secondary_placements
    expect(page).not_to have_table_row({
      "Subject" => "Music",
      "Expected date" => "Any time in the academic year",
      "School" => "Ogdenville Observatoire",
    })

    expect(page).not_to have_table_row({
      "Subject" => "Music",
      "Expected date" => "Any time in the academic year",
      "School" => "Shelbyville High School",
    })
  end

  def and_i_do_not_see_the_secondary_phase_checkbox_selected
    expect(page).to have_field("Secondary", type: "checkbox", checked: false)
    expect(page).to have_field("Primary", type: "checkbox", checked: true)
  end

  def and_i_do_not_see_the_secondary_filter_tag
    expect(page).to have_h3("Phase")
    expect(page).not_to have_filter_tag("Secondary")
    expect(page).to have_filter_tag("Primary")
  end

  def when_i_click_on_the_primary_phase_tag
    within ".app-filter-tags" do
      click_on "Primary"
    end
  end

  def and_i_do_not_see_any_selected_phase_checkboxes
    expect(page).to have_field("Secondary", type: "checkbox", checked: false)
    expect(page).to have_field("Primary", type: "checkbox", checked: false)
  end

  def and_i_do_not_see_any_phase_filter_tags
    expect(page).not_to have_h3("Phase")
    expect(page).not_to have_filter_tag("Secondary")
    expect(page).not_to have_filter_tag("Primary")
  end
end
