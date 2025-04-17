require "rails_helper"

RSpec.describe "Provider user filters schools by last offered placements", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_all_schools
    and_i_see_the_last_offered_placements_filter

    when_i_select_no_recent_placements
    and_i_click_on_apply_filters
    then_i_see_the_school_with_no_recent_placements
    and_i_do_not_see_the_school_with_recent_placements
    and_i_see_that_the_no_recent_placements_checkbox_is_selected
    and_i_see_the_no_recent_placements_filter_tag

    when_i_select_recent_placements_from_the_last_offered_placements_filter
    and_i_click_on_apply_filters
    then_i_see_all_schools
    and_i_see_that_the_recent_placements_and_no_recent_placements_checkboxes_are_selected
    and_i_see_the_recent_placements_and_no_recent_placements_filter_tags

    when_i_click_on_the_no_recent_placements_filter_tag
    then_i_see_the_school_with_recent_placements
    and_i_do_not_see_the_school_with_no_recent_placements
    and_i_do_not_see_the_no_recent_placements_checkbox_selected
    and_i_do_not_see_the_no_recent_placements_filter_tag

    when_i_click_on_the_recent_placements_filter_tag
    then_i_see_all_schools
    and_i_do_not_see_any_selected_last_offered_placements_checkboxes
    and_i_do_not_see_any_last_offered_placements_filter_tags
  end

  private

  def given_that_schools_exist
    @previous_academic_year = Placements::AcademicYear.current.previous
    @provider = build(:placements_provider, name: "Aes Sedai Trust")

    @primary_school_no_placement = create(:placements_school, phase: "Primary", name: "Springfield Elementary")

    @primary_school_with_previous_placement = build(:placements_school, phase: "Primary", name: "Hogwarts Elementary")
    _primary_english_placement = create(:placement, school: @primary_school_with_previous_placement, academic_year: @previous_academic_year)
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
    expect(page).to have_h2("Hogwarts Elementary")
  end

  def and_i_see_the_last_offered_placements_filter
    expect(page).to have_element(:legend, text: "Last offered placements", class: "govuk-fieldset__legend")
    expect(page).to have_unchecked_field(@previous_academic_year.name)
    expect(page).to have_unchecked_field("No recent placements")
  end

  def when_i_select_no_recent_placements
    check "No recent placements"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_school_with_no_recent_placements
    expect(page).to have_h2("Springfield Elementary")
  end

  def and_i_do_not_see_the_school_with_recent_placements
    expect(page).not_to have_h2("Hogwarts Elementary")
  end

  def then_i_see_the_school_with_recent_placements
    expect(page).to have_h2("Hogwarts Elementary")
  end

  def and_i_do_not_see_the_school_with_no_recent_placements
    expect(page).not_to have_h2("Springfield Elementary")
  end

  def and_i_see_that_the_no_recent_placements_checkbox_is_selected
    expect(page).to have_checked_field("No recent placements")
  end

  def and_i_see_the_no_recent_placements_filter_tag
    expect(page).to have_filter_tag("No recent placements")
  end

  def when_i_select_recent_placements_from_the_last_offered_placements_filter
    check @previous_academic_year.name
  end

  def and_i_see_that_the_recent_placements_and_no_recent_placements_checkboxes_are_selected
    expect(page).to have_checked_field(@previous_academic_year.name)
    expect(page).to have_checked_field("No recent placements")
  end

  def and_i_see_the_recent_placements_and_no_recent_placements_filter_tags
    expect(page).to have_filter_tag(@previous_academic_year.name)
    expect(page).to have_filter_tag("No recent placements")
  end

  def when_i_click_on_the_no_recent_placements_filter_tag
    within ".app-filter-tags" do
      click_on "No recent placements"
    end
  end

  def and_i_do_not_see_the_no_recent_placements_checkbox_selected
    expect(page).to have_checked_field(@previous_academic_year.name)
    expect(page).to have_unchecked_field("No recent placements")
  end

  def and_i_do_not_see_the_no_recent_placements_filter_tag
    expect(page).not_to have_filter_tag("No recent placements")
  end

  def when_i_click_on_the_recent_placements_filter_tag
    within ".app-filter-tags" do
      click_on @previous_academic_year.name
    end
  end

  def then_i_see_all_schools
    expect(page).to have_h2("Springfield Elementary")
    expect(page).to have_h2("Hogwarts Elementary")
  end

  def and_i_do_not_see_any_selected_last_offered_placements_checkboxes
    expect(page).to have_unchecked_field(@previous_academic_year.name)
    expect(page).to have_unchecked_field("No recent placements")
  end

  def and_i_do_not_see_any_last_offered_placements_filter_tags
    expect(page).not_to have_h3("Last offered placements")
    expect(page).not_to have_filter_tag(@previous_academic_year.name)
    expect(page).not_to have_filter_tag("No recent placements")
  end
end
