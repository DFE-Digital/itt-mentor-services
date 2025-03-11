require "rails_helper"

RSpec.describe "Provider user filters schools by phase", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_the_provider_find_a_school_feature_is_enabled
    and_i_am_signed_in

    when_i_navigate_to_the_find_index_page
    then_i_am_on_the_find_index_page
    and_i_see_all_schools
    and_i_see_the_phase_filter

    when_i_select_primary_from_the_phase_filter
    and_i_click_on_apply_filters
    then_i_see_springfield_elementary
    and_i_do_not_see_springfield_high
    and_i_see_my_selected_phase_filter

    when_i_select_secondary_from_the_phase_filter
    and_i_click_on_apply_filters
    then_i_see_all_schools
    and_i_see_my_selected_phase_filters

    when_i_click_on_the_secondary_phase_filter_tag
    then_i_see_springfield_elementary
    and_i_do_not_see_springfield_high
    and_i_do_not_see_the_secondary_phase_filter

    when_i_click_on_the_primary_phase_filter_tag
    then_i_see_all_schools
    and_i_do_not_see_any_selected_phase_filters
  end

  private

  def given_that_schools_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")
    @secondary_school = build(:placements_school, phase: "Secondary", name: "Springfield High")
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def and_the_provider_find_a_school_feature_is_enabled
    Flipper.enable(:provider_find_a_school)
  end

  def when_i_navigate_to_the_find_index_page
    within ".app-primary-navigation__nav" do
      click_on "Find"
    end
  end

  def then_i_am_on_the_find_index_page
    expect(page).to have_title("Find schools and placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Find schools and placements")
    expect(page).to have_h2("Filter")
  end

  def then_i_see_all_schools
    expect(page).to have_h2("Springfield Elementary")
    expect(page).to have_h2("Springfield High")
  end

  alias_method :and_i_see_all_schools, :then_i_see_all_schools

  def and_i_see_the_phase_filter
    expect(page).to have_element(:legend, text: "Phase", class: "govuk-fieldset__legend")
    expect(page).to have_field("Primary", type: :checkbox, unchecked: true)
    expect(page).to have_field("Secondary", type: :checkbox, unchecked: true)
  end

  def when_i_select_primary_from_the_phase_filter
    check "Primary"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_springfield_elementary
    expect(page).to have_h2("Springfield Elementary")
  end

  def and_i_do_not_see_springfield_high
    expect(page).not_to have_h2("Springfield high")
  end

  def and_i_see_my_selected_phase_filter
    expect(page).to have_filter_tag("Primary")
    expect(page).to have_checked_field("Primary")
    expect(page).not_to have_filter_tag("Secondary")
    expect(page).not_to have_checked_field("Secondary")
  end

  def when_i_select_secondary_from_the_phase_filter
    check "Secondary"
  end

  def and_i_see_my_selected_phase_filters
    expect(page).to have_filter_tag("Primary")
    expect(page).to have_checked_field("Primary")
    expect(page).to have_filter_tag("Secondary")
    expect(page).to have_checked_field("Secondary")
  end

  def when_i_click_on_the_primary_phase_filter_tag
    within ".app-filter-tags" do
      click_on "Primary"
    end
  end

  def then_i_see_springfield_high
    expect(page).to have_h2("Springfield High")
  end

  def and_i_do_not_see_springfield_elementary
    expect(page).not_to have_h2("Springfield Elementary")
  end

  def and_i_do_not_see_the_primary_phase_filter
    expect(page).not_to have_filter_tag("Primary")
    expect(page).not_to have_checked_field("Primary")
    expect(page).to have_filter_tag("mathematics")
    expect(page).to have_checked_field("Secondary")
  end

  def when_i_click_on_the_secondary_phase_filter_tag
    within ".app-filter-tags" do
      click_on "Secondary"
    end
  end

  def and_i_do_not_see_the_secondary_phase_filter
    expect(page).not_to have_filter_tag("Secondary")
    expect(page).not_to have_checked_field("Secondary")
  end

  def and_i_do_not_see_any_selected_phase_filters
    expect(page).not_to have_filter_tag("Primary")
    expect(page).not_to have_checked_field("Primary")
    expect(page).not_to have_filter_tag("mathematics")
    expect(page).not_to have_checked_field("mathematics")
  end
end
