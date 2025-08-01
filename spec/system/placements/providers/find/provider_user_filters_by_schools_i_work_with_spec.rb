require "rails_helper"

RSpec.describe "Provider user filters schools by schools I work with", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_all_schools
    and_i_see_the_schools_i_work_with_filter

    when_i_select_springfield_elementary_from_the_schools_i_work_with_filter
    and_i_click_on_apply_filters
    then_i_see_the_springfield_elementary_school
    and_i_do_not_see_the_hogwarts_elementary_school
    and_i_see_my_selected_springfield_elementary_school_filters

    when_i_select_hogwarts_elementary_from_the_schools_i_work_with_filter
    and_i_click_on_apply_filters
    then_i_see_all_schools
    and_i_see_my_selected_schools_i_work_with_filters

    when_i_click_on_the_springfield_elementary_subject_filter_tag
    then_i_see_the_hogwarts_elementary_school
    and_i_do_not_see_the_springfield_elementary_school
    and_i_do_not_see_the_springfield_elementary_school_filter_tag

    when_i_click_on_the_hogwarts_elementary_subject_filter_tag
    then_i_see_all_schools
    and_i_do_not_see_any_selected_schools_i_work_with_filters
  end

  private

  def given_that_schools_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")

    @primary_school_with_maths = build(:placements_school, phase: "Primary", name: "Springfield Elementary", partner_providers: [@provider])
    @primary_maths_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    _primary_maths_placement = create(:placement, school: @primary_school_with_maths, subject: @primary_maths_subject)

    @primary_school_with_english = build(:placements_school, phase: "Primary", name: "Hogwarts Elementary", partner_providers: [@provider])
    @primary_english_subject = build(:subject, name: "Primary with english", subject_area: "primary")
    _primary_english_placement = create(:placement, school: @primary_school_with_english, subject: @primary_english_subject)
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

  def and_i_see_the_schools_i_work_with_filter
    expect(page).to have_element(:legend, text: "Schools I work with", class: "govuk-fieldset__legend")
    expect(page).to have_field("Springfield Elementary", type: :checkbox, unchecked: true)
    expect(page).to have_field("Hogwarts Elementary", type: :checkbox, unchecked: true)
  end

  def when_i_select_springfield_elementary_from_the_schools_i_work_with_filter
    check "Springfield Elementary"
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

  def and_i_see_my_selected_springfield_elementary_school_filters
    expect(page).to have_filter_tag("Springfield Elementary")
    expect(page).to have_checked_field("Springfield Elementary")
    expect(page).not_to have_filter_tag("Hogwarts Elementary")
    expect(page).not_to have_checked_field("Hogwarts Elementary")
  end

  def when_i_select_hogwarts_elementary_from_the_schools_i_work_with_filter
    check "Hogwarts Elementary"
  end

  def and_i_see_my_selected_schools_i_work_with_filters
    expect(page).to have_filter_tag("Springfield Elementary")
    expect(page).to have_checked_field("Springfield Elementary")
    expect(page).to have_filter_tag("Hogwarts Elementary")
    expect(page).to have_checked_field("Hogwarts Elementary")
  end

  def when_i_click_on_the_springfield_elementary_subject_filter_tag
    within ".app-filter-tags" do
      click_on "Springfield Elementary"
    end
  end

  def then_i_see_the_hogwarts_elementary_school
    expect(page).to have_h2("Hogwarts Elementary")
  end

  def and_i_do_not_see_the_springfield_elementary_school
    expect(page).not_to have_h2("Springfield Elementary")
  end

  def and_i_do_not_see_the_springfield_elementary_school_filter_tag
    expect(page).not_to have_filter_tag("Springfield Elementary")
    expect(page).not_to have_checked_field("Springfield Elementary")
    expect(page).to have_filter_tag("Hogwarts Elementary")
    expect(page).to have_checked_field("Hogwarts Elementary")
  end

  def when_i_click_on_the_hogwarts_elementary_subject_filter_tag
    within ".app-filter-tags" do
      click_on "Hogwarts Elementary"
    end
  end

  def and_i_do_not_see_any_selected_schools_i_work_with_filters
    expect(page).not_to have_filter_tag("Springfield Elementary")
    expect(page).not_to have_checked_field("Springfield Elementary")
    expect(page).not_to have_filter_tag("Hogwarts Elementary")
    expect(page).not_to have_checked_field("Hogwarts Elementary")
  end
end
