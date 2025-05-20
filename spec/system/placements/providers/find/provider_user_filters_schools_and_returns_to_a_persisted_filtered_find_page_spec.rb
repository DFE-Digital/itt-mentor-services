require "rails_helper"

RSpec.describe "Provider user filters schools and returns to a persisted filtered find page", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_all_schools
    and_i_see_the_itt_status_filter

    when_i_select_open_to_hosting_from_the_itt_status_filter
    and_i_select_not_hosting_from_the_itt_status_filter
    and_i_click_on_apply_filters
    then_i_see_all_schools
    and_i_see_that_the_open_to_hosting_and_not_hosting_itt_status_checkboxes_are_selected
    and_i_see_that_the_open_to_hosting_and_not_hosting_filter_tags

    when_i_click_on_springfield_elementary_school
    then_i_see_the_springfield_elementary_school_placement_info_page

    when_i_click_on_back
    then_i_see_the_find_schools_page
    then_i_see_all_schools
    and_i_see_that_the_open_to_hosting_and_not_hosting_itt_status_checkboxes_are_selected
    and_i_see_that_the_open_to_hosting_and_not_hosting_filter_tags
  end

  private

  def given_that_schools_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")

    @open_hosting_interest = build(:hosting_interest, appetite: "interested", academic_year: Placements::AcademicYear.current.next)
    @not_open_hosting_interest = build(:hosting_interest, appetite: "not_open", academic_year: Placements::AcademicYear.current.next)

    @open_to_hosting_school = create(:placements_school, phase: "Primary", name: "Springfield Elementary", hosting_interests: [@open_hosting_interest])
    @not_hosting_school = create(:placements_school, phase: "Secondary", name: "Shelbyville High School", hosting_interests: [@not_open_hosting_interest])
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

  def and_i_see_the_itt_status_filter
    expect(page).to have_element(:legend, text: "ITT status", class: "govuk-fieldset__legend")
    expect(page).to have_unchecked_field("May offer placements")
    expect(page).to have_unchecked_field("Not offering placements")
    expect(page).to have_unchecked_field("No placements available")
    expect(page).to have_unchecked_field("Placements available")
  end

  def when_i_select_open_to_hosting_from_the_itt_status_filter
    check "May offer placements"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_open_to_hosting_school
    expect(page).to have_h2("Springfield Elementary")
  end

  def and_i_do_not_see_the_not_open_to_hosting_school
    expect(page).not_to have_h2("Shelbyville High School")
  end

  def and_i_see_that_the_open_to_hosting_itt_status_checkbox_is_selected
    expect(page).to have_checked_field("May offer placements")
  end

  def and_i_see_the_open_to_hosting_filter_tag
    expect(page).to have_filter_tag("May offer placements")
  end

  def and_i_select_not_hosting_from_the_itt_status_filter
    check "Not offering placements"
  end

  def and_i_see_that_the_open_to_hosting_and_not_hosting_itt_status_checkboxes_are_selected
    expect(page).to have_checked_field("May offer placements")
    expect(page).to have_checked_field("Not offering placements")
  end

  def and_i_see_that_the_open_to_hosting_and_not_hosting_filter_tags
    expect(page).to have_filter_tag("May offer placements")
    expect(page).to have_filter_tag("Not offering placements")
  end

  def when_i_click_on_the_not_hosting_itt_status_tag
    within ".app-filter-tags" do
      click_on "Not offering placements"
    end
  end

  def and_i_do_not_see_the_not_opening_itt_status_checkbox_selected
    expect(page).to have_checked_field("May offer placements")
    expect(page).to have_unchecked_field("Not offering placements")
  end

  def and_i_do_not_see_the_not_open_filter_tag
    expect(page).not_to have_filter_tag("Not offering placements")
  end

  def when_i_click_on_the_open_to_hosting_itt_status_tag
    within ".app-filter-tags" do
      click_on "May offer placements"
    end
  end

  def then_i_see_all_schools
    expect(page).to have_h2("Springfield Elementary")
    expect(page).to have_h2("Shelbyville High School")
  end

  def and_i_do_not_see_any_selected_itt_status_checkboxes
    expect(page).to have_unchecked_field("May offer placements")
    expect(page).to have_unchecked_field("Not offering placements")
  end

  def and_i_do_not_see_any_itt_status_filter_tags
    expect(page).not_to have_h3("ITT status")
    expect(page).not_to have_filter_tag("May offer placements")
    expect(page).not_to have_filter_tag("Not offering placements")
  end

  def when_i_click_on_springfield_elementary_school
    click_on "Springfield Elementary"
  end

  def then_i_see_the_springfield_elementary_school_placement_info_page
    expect(page).to have_title("Springfield Elementary - Find - Manage school placements - GOV.UK")
    expect(page).to have_h1("Springfield Elementary")
    expect(page).to have_current_path("/providers/#{@provider.id}/find/#{@open_to_hosting_school.id}/placement_information")
  end

  def when_i_click_on_back
    click_on "Back"
  end
end
