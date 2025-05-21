require "rails_helper"

RSpec.describe "Provider user filters schools by subject", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_all_schools
    and_i_see_the_subject_filter

    when_i_select_maths_from_the_subject_filter
    and_i_click_on_apply_filters
    then_i_see_the_secondary_school_with_the_maths_placement
    and_i_do_not_see_the_secondary_school_with_the_english_placement
    and_i_see_my_selected_subject_filter

    when_i_select_english_from_the_subject_filter
    and_i_click_on_apply_filters
    then_i_see_all_schools
    and_i_see_my_selected_subject_filters

    when_i_click_on_the_maths_subject_filter_tag
    then_i_see_the_primary_school_with_the_english_placement
    and_i_do_not_see_the_primary_school_with_the_maths_placement
    and_i_do_not_see_the_primary_with_maths_subject_filter

    when_i_click_on_the_primary_with_english_subject_filter_tag
    then_i_see_all_schools
    and_i_do_not_see_any_selected_subject_filters
  end

  private

  def given_that_schools_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")

    @school_with_maths = build(:placements_school, phase: "Secondary", name: "Springfield Elementary")
    @maths_subject = build(:subject, name: "Mathematics", subject_area: "secondary")
    _maths_placement = create(:placement, school: @school_with_maths, subject: @maths_subject)

    @school_with_english = build(:placements_school, phase: "Secondary", name: "Hogwarts Elementary")
    @english_subject = build(:subject, name: "English", subject_area: "secondary")
    _english_placement = create(:placement, school: @school_with_english, subject: @english_subject)
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
  alias_method :then_i_see_all_schools, :and_i_see_all_schools

  def and_i_see_the_subject_filter
    expect(page).to have_element(:legend, text: "Secondary subject", class: "govuk-fieldset__legend")
    expect(page).to have_field("Mathematics", type: :checkbox, checked: false)
    expect(page).to have_field("English", type: :checkbox, unchecked: true)
  end

  def when_i_select_maths_from_the_subject_filter
    check "Mathematics"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_secondary_school_with_the_maths_placement
    expect(page).to have_h2("Springfield Elementary")
  end

  def and_i_do_not_see_the_secondary_school_with_the_english_placement
    expect(page).not_to have_h2("Hogwarts Elementary")
  end

  def and_i_see_my_selected_subject_filter
    expect(page).to have_filter_tag("Mathematics")
    expect(page).to have_checked_field("Mathematics")
    expect(page).not_to have_filter_tag("English")
    expect(page).not_to have_checked_field("English")
  end

  def when_i_select_english_from_the_subject_filter
    check "English"
  end

  def and_i_see_my_selected_subject_filters
    expect(page).to have_filter_tag("Mathematics")
    expect(page).to have_checked_field("Mathematics")
    expect(page).to have_filter_tag("English")
    expect(page).to have_checked_field("English")
  end

  def when_i_click_on_the_maths_subject_filter_tag
    within ".app-filter-tags" do
      click_on "Mathematics"
    end
  end

  def then_i_see_the_primary_school_with_the_english_placement
    expect(page).to have_h2("Hogwarts Elementary")
  end

  def and_i_do_not_see_the_primary_school_with_the_maths_placement
    expect(page).not_to have_h2("Springfield Elementary")
  end

  def and_i_do_not_see_the_primary_with_maths_subject_filter
    expect(page).not_to have_filter_tag("Mathematics")
    expect(page).not_to have_checked_field("Mathematics")
    expect(page).to have_filter_tag("English")
    expect(page).to have_checked_field("English")
  end

  def when_i_click_on_the_primary_with_english_subject_filter_tag
    within ".app-filter-tags" do
      click_on "English"
    end
  end

  def and_i_do_not_see_any_selected_subject_filters
    expect(page).not_to have_filter_tag("Mathematics")
    expect(page).not_to have_checked_field("Mathematics")
    expect(page).not_to have_filter_tag("English")
    expect(page).not_to have_checked_field("English")
  end
end
