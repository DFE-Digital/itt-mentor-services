require "rails_helper"

RSpec.describe "Provider user filters schools by year groups", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_all_schools
    and_i_see_the_year_group_filter

    when_i_select_year_1_from_the_year_group_filter
    and_i_click_on_apply_filters
    then_i_see_the_springfield_elementary_school
    and_i_do_not_see_the_hogwarts_elementary_school
    and_i_only_see_the_year_1_filter_selected

    when_i_select_year_2_from_the_from_the_year_group
    and_i_click_on_apply_filters
    then_i_see_all_schools
    and_i_only_see_the_year_1_and_year_2_filters_selected

    when_i_click_on_the_year_1_filter_tag
    then_i_see_the_hogwarts_elementary_school
    and_i_do_not_see_the_springfield_elementary_school
    and_i_do_not_see_the_year_1_filter_tag

    when_i_click_on_the_year_2_filter_tag
    then_i_see_all_schools
    and_i_do_not_see_any_year_group_filters
  end

  private

  def given_that_schools_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @primary_subject = build(:subject, name: "Primary", subject_area: "primary")

    @year_1_primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary", partner_providers: [@provider])
    _year_1_placement = create(:placement, school: @year_1_primary_school, subject: @primary_subject, year_group: "year_1")

    @year_2_primary_school = build(:placements_school, phase: "Primary", name: "Hogwarts Elementary", partner_providers: [@provider])
    _year_2_placement = create(:placement, school: @year_2_primary_school, subject: @primary_subject, year_group: "year_2")
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def when_i_navigate_to_the_find_schools_page
    within primary_navigation do
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
  alias_method :then_i_see_all_schools, :and_i_see_all_schools

  def and_i_see_the_year_group_filter
    expect(page).to have_element(:legend, text: "Primary year group", class: "govuk-fieldset__legend")
    expect(page).to have_field("Nursery", type: :checkbox, unchecked: true)
    expect(page).to have_field("Reception", type: :checkbox, unchecked: true)
    expect(page).to have_field("Year 1", type: :checkbox, unchecked: true)
    expect(page).to have_field("Year 2", type: :checkbox, unchecked: true)
    expect(page).to have_field("Year 3", type: :checkbox, unchecked: true)
    expect(page).to have_field("Year 4", type: :checkbox, unchecked: true)
    expect(page).to have_field("Year 5", type: :checkbox, unchecked: true)
    expect(page).to have_field("Mixed year groups", type: :checkbox, unchecked: true)
  end

  def when_i_select_year_1_from_the_year_group_filter
    check "Year 1"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_springfield_elementary_school
    expect(page).to have_h2("Springfield Elementary")
  end

  def and_i_do_not_see_the_hogwarts_elementary_school
    expect(page).not_to have_h2("Hogwarts Elementary")
  end

  def and_i_only_see_the_year_1_filter_selected
    expect(page).to have_filter_tag("Year 1")
    expect(page).to have_checked_field("Year 1")

    expect(page).not_to have_filter_tag("Nursery")
    expect(page).not_to have_checked_field("Nursery")
    expect(page).not_to have_filter_tag("Reception")
    expect(page).not_to have_checked_field("Reception")
    expect(page).not_to have_filter_tag("Year 2")
    expect(page).not_to have_checked_field("Year 2")
    expect(page).not_to have_filter_tag("Year 3")
    expect(page).not_to have_checked_field("Year 3")
    expect(page).not_to have_filter_tag("Year 4")
    expect(page).not_to have_checked_field("Year 4")
    expect(page).not_to have_filter_tag("Year 5")
    expect(page).not_to have_checked_field("Year 5")
    expect(page).not_to have_filter_tag("Mixed year groups")
    expect(page).not_to have_checked_field("Mixed year groups")
  end

  def when_i_select_year_2_from_the_from_the_year_group
    check "Year 2"
  end

  def and_i_only_see_the_year_1_and_year_2_filters_selected
    expect(page).to have_filter_tag("Year 1")
    expect(page).to have_checked_field("Year 1")
    expect(page).to have_filter_tag("Year 2")
    expect(page).to have_checked_field("Year 2")

    expect(page).not_to have_filter_tag("Nursery")
    expect(page).not_to have_checked_field("Nursery")
    expect(page).not_to have_filter_tag("Reception")
    expect(page).not_to have_checked_field("Reception")
    expect(page).not_to have_filter_tag("Year 3")
    expect(page).not_to have_checked_field("Year 3")
    expect(page).not_to have_filter_tag("Year 4")
    expect(page).not_to have_checked_field("Year 4")
    expect(page).not_to have_filter_tag("Year 5")
    expect(page).not_to have_checked_field("Year 5")
    expect(page).not_to have_filter_tag("Mixed year groups")
    expect(page).not_to have_checked_field("Mixed year groups")
  end

  def and_i_see_my_selected_schools_i_work_with_filters
    expect(page).to have_filter_tag("Springfield Elementary")
    expect(page).to have_checked_field("Springfield Elementary")
    expect(page).to have_filter_tag("Hogwarts Elementary")
    expect(page).to have_checked_field("Hogwarts Elementary")
  end

  def then_i_see_the_hogwarts_elementary_school
    expect(page).to have_h2("Hogwarts Elementary")
  end

  def and_i_do_not_see_the_springfield_elementary_school
    expect(page).not_to have_h2("Springfield Elementary")
  end

  def when_i_click_on_the_year_1_filter_tag
    within ".app-filter-tags" do
      click_on "Year 1"
    end
  end

  def when_i_click_on_the_year_2_filter_tag
    within ".app-filter-tags" do
      click_on "Year 2"
    end
  end

  def and_i_do_not_see_the_year_1_filter_tag
    expect(page).not_to have_filter_tag("Year 1")
    expect(page).not_to have_checked_field("Year 1")
    expect(page).to have_filter_tag("Year 2")
    expect(page).to have_checked_field("Year 2")
  end

  def and_i_do_not_see_any_year_group_filters
    expect(page).not_to have_filter_tag("Year 1")
    expect(page).not_to have_checked_field("Year 1")
    expect(page).not_to have_filter_tag("Year 2")
    expect(page).not_to have_checked_field("Year 2")
  end
end
