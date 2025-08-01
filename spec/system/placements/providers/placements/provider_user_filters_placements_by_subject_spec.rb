require "rails_helper"

RSpec.describe "Provider user filters placements by subject", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_navigate_to_the_placements_index_page
    then_i_am_on_the_placements_index_page
    and_i_see_all_placements
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
    academic_year = Placements::AcademicYear.current.next
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")

    @primary_maths_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    _primary_maths_placement = create(:placement, school: @primary_school, subject: @primary_maths_subject, provider: @provider, academic_year:)

    @primary_english_subject = build(:subject, name: "Primary with english", subject_area: "primary")
    _primary_english_placement = create(:placement, school: @primary_school, subject: @primary_english_subject, provider: @provider, academic_year:)
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
      "Subject" => "Primary with mathematics",
      "Expected date" => "Any time in the academic year",
      "School" => "Springfield Elementary",
    })

    expect(page).to have_table_row({
      "Subject" => "Primary with english",
      "Expected date" => "Any time in the academic year",
      "School" => "Springfield Elementary",
    })
  end
  alias_method :then_i_see_all_placements, :and_i_see_all_placements

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
    expect(page).to have_table_row({
      "Subject" => "Primary with mathematics",
      "Expected date" => "Any time in the academic year",
      "School" => "Springfield Elementary",
    })
  end

  def and_i_do_not_see_the_primary_with_english_placement
    expect(page).not_to have_table_row({
      "Subject" => "Primary with english",
      "Expected date" => "Any time in the academic year",
      "School" => "Springfield Elementary",
    })
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
    expect(page).to have_table_row({
      "Subject" => "Primary with english",
      "Expected date" => "Any time in the academic year",
      "School" => "Springfield Elementary",
    })
  end

  def and_i_do_not_see_the_primary_with_maths_placement
    expect(page).not_to have_table_row({
      "Subject" => "Primary with mathematics",
      "Expected date" => "Any time in the academic year",
      "School" => "Springfield Elementary",
    })
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
