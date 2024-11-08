require "rails_helper"

RSpec.describe "Provider user filters placements by subject", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_all_placements
    and_i_see_the_subject_filter

    when_i_select_primary_with_maths_from_the_subject_filter
    and_i_click_on_apply_filters
    then_i_see_the_primary_with_maths_placement
    and_i_do_not_see_the_primary_with_english_placement
    and_i_see_my_selected_subject_filter

    when_i_select_primary_with_english_from_the_subject_filter
    and_i_click_on_apply_filters
    then_i_see_all_placements
    and_i_see_my_selected_subject_filters

    when_i_click_on_the_primary_with_maths_subject_filter_tag
    then_i_see_the_primary_with_english_placement
    and_i_do_not_see_the_primary_with_maths_placement
    and_i_do_not_see_the_primary_with_maths_subject_filter

    when_i_click_on_the_primary_with_english_subject_filter_tag
    then_i_see_all_placements
    and_i_do_not_see_any_selected_subject_filters
  end

  private

  def given_that_placements_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")

    @primary_maths_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    _primary_maths_placement = create(:placement, school: @primary_school, subject: @primary_maths_subject)

    @primary_english_subject = build(:subject, name: "Primary with english", subject_area: "primary")
    _primary_english_placement = create(:placement, school: @primary_school, subject: @primary_english_subject)
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def when_i_am_on_the_placements_index_page
    expect(page).to have_title("Find placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Find placements")
    expect(page).to have_h2("Filter")
  end

  def then_i_see_all_placements
    expect(page).to have_h2("Primary with mathematics – Springfield Elementary")
    expect(page).to have_h2("Primary with english – Springfield Elementary")
  end

  def and_i_see_the_subject_filter
    expect(page).to have_element(:legend, text: "Subject", class: "govuk-fieldset__legend")
    expect(page).to have_field("Primary with mathematics", type: :checkbox, checked: false)
    expect(page).to have_field("Primary with english", type: :checkbox, unchecked: true)
  end

  def when_i_select_primary_with_maths_from_the_subject_filter
    check "Primary with mathematics"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_primary_with_maths_placement
    expect(page).to have_h2("Primary with mathematics – Springfield Elementary")
  end

  def and_i_do_not_see_the_primary_with_english_placement
    expect(page).not_to have_h2("Primary with english – Springfield Elementary")
  end

  def and_i_see_my_selected_subject_filter
    expect(page).to have_filter_tag("Primary with mathematics")
    expect(page).to have_checked_field("Primary with mathematics")
    expect(page).not_to have_filter_tag("Primary with english")
    expect(page).not_to have_checked_field("Primary with english")
  end

  def when_i_select_primary_with_english_from_the_subject_filter
    check "Primary with english"
  end

  def and_i_see_my_selected_subject_filters
    expect(page).to have_filter_tag("Primary with mathematics")
    expect(page).to have_checked_field("Primary with mathematics")
    expect(page).to have_filter_tag("Primary with english")
    expect(page).to have_checked_field("Primary with english")
  end

  def when_i_click_on_the_primary_with_maths_subject_filter_tag
    within ".app-filter-tags" do
      click_on "Primary with mathematics"
    end
  end

  def then_i_see_the_primary_with_english_placement
    expect(page).to have_h2("Primary with english – Springfield Elementary")
  end

  def and_i_do_not_see_the_primary_with_maths_placement
    expect(page).not_to have_h2("Primary with mathematics – Springfield Elementary")
  end

  def and_i_do_not_see_the_primary_with_maths_subject_filter
    expect(page).not_to have_filter_tag("Primary with mathematics")
    expect(page).not_to have_checked_field("Primary with mathematics")
    expect(page).to have_filter_tag("Primary with english")
    expect(page).to have_checked_field("Primary with english")
  end

  def when_i_click_on_the_primary_with_english_subject_filter_tag
    within ".app-filter-tags" do
      click_on "Primary with english"
    end
  end

  def and_i_do_not_see_any_selected_subject_filters
    expect(page).not_to have_filter_tag("Primary with mathematics")
    expect(page).not_to have_checked_field("Primary with mathematics")
    expect(page).not_to have_filter_tag("Primary with english")
    expect(page).not_to have_checked_field("Primary with english")
  end
end
