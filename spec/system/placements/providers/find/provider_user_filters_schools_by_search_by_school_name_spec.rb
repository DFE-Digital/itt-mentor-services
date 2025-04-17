require "rails_helper"

RSpec.describe "Provider user filters schools by search by location", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_all_schools
    and_i_see_the_search_by_school_name_filter

    when_i_search_for_springfield_elementary
    and_i_click_on_apply_filters
    then_i_see_springfield_elementary
    and_i_do_not_see_shelbyville_high_school
    and_i_see_the_springfield_elementary_search_by_name_filter

    when_i_click_on_the_springfield_elementary_search_by_name_filter_tag
    then_i_see_all_schools
    and_i_do_not_see_the_springfield_search_by_name_filter

    when_i_search_for_a_school_that_doesnt_exist
    and_i_click_on_apply_filters
    then_i_see_no_schools
    and_i_see_my_made_up_school_name_search_by_name_filter

    when_i_click_on_the_made_up_school_name_search_by_name_filter_tag
    then_i_see_all_schools
    and_i_do_not_see_the_hogwarts_search_by_name_filter
  end

  private

  def given_that_schools_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")

    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")
    @secondary_school = build(:placements_school, phase: "Secondary", name: "Shelbyville High School")
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
    expect(page).to have_content(@primary_school.name)
    expect(page).to have_content(@secondary_school.name)
  end

  def and_i_see_the_search_by_school_name_filter
    expect(page).to have_element(:label, text: "Search by school name")
    expect(page).to have_field("Enter a school name or URN", type: :search)
  end

  def when_i_search_for_springfield_elementary
    fill_in "Enter a school name or URN", with: "springfield elementary"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_springfield_elementary
    expect(page).to have_h2("Springfield Elementary")
  end

  def and_i_do_not_see_shelbyville_high_school
    expect(page).not_to have_h2("Shelbyville High School")
  end

  def and_i_see_the_springfield_elementary_search_by_name_filter
    expect(page).to have_filter_tag("springfield elementary")
    expect(page).to have_field("Enter a school name or URN", type: :search, with: "springfield elementary")
  end

  def when_i_click_on_the_springfield_elementary_search_by_name_filter_tag
    within ".app-filter-tags" do
      click_on "springfield elementary"
    end
  end

  def then_i_see_all_schools
    expect(page).to have_content(@primary_school.name)
    expect(page).to have_content(@secondary_school.name)
  end

  def and_i_do_not_see_the_springfield_search_by_name_filter
    expect(page).not_to have_filter_tag("springfield elementary")
    expect(page).not_to have_field("Enter a school name or URN", type: :search, with: "springfield elementary")
  end

  def when_i_search_for_a_school_that_doesnt_exist
    fill_in "Enter a school name or URN", with: "Hogwarts"
  end

  def then_i_see_no_schools
    expect(page).to have_h2("No schools")
    expect(page).to have_element(:p, text: "There are no schools that match your selection. Try searching again, or removing one or more filters.")
  end

  def and_i_see_my_made_up_school_name_search_by_name_filter
    expect(page).to have_filter_tag("Hogwarts")
    expect(page).to have_field("Enter a school name or URN", type: :search, with: "Hogwarts")
  end

  def when_i_click_on_the_made_up_school_name_search_by_name_filter_tag
    within ".app-filter-tags" do
      click_on "Hogwarts"
    end
  end

  def and_i_do_not_see_the_hogwarts_search_by_name_filter
    expect(page).not_to have_filter_tag("Hogwarts")
    expect(page).not_to have_field("Enter a school name or URN", type: :search, with: "Hogwarts")
  end
end
