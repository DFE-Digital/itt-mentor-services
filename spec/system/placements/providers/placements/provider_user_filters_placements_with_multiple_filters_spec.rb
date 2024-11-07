require "rails_helper"

RSpec.describe "Provider user filters placements with multiple filters", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_all_placements
    and_i_see_all_filters

    when_i_check_multiple_filters
    and_i_click_on_apply_filters
    then_i_see_the_primary_with_maths_placement
    and_i_do_not_see_the_primary_with_english_placement
    and_i_see_my_selected_filters

    when_i_click_on_clear_filters
    then_i_see_all_placements
    and_i_do_not_see_any_selected_filters
  end

  private

  def given_that_placements_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")
    @autumn_term = build(:placements_term, :autumn)

    @primary_maths_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    _primary_maths_placement = create(:placement, school: @primary_school, subject: @primary_maths_subject,
                                                  terms: [@autumn_term])

    @primary_english_subject = build(:subject, name: "Primary with english", subject_area: "primary")
    _primary_english_placement = create(:placement, school: @primary_school, subject: @primary_english_subject,
                                                    terms: [@autumn_term])
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

  def and_i_see_all_filters
    expect(page).to have_element(:label, text: "Search by location", class: "govuk-label govuk-label--s")
    expect(page).to have_element(:legend, text: "Placements to show", class: "govuk-fieldset__legend")
    expect(page).to have_element(:legend, text: "Academic year", class: "govuk-fieldset__legend")
    expect(page).to have_element(:legend, text: "Expected date", class: "govuk-fieldset__legend")
    expect(page).to have_element(:legend, text: "Subject", class: "govuk-fieldset__legend")
    expect(page).to have_element(:legend, text: "Primary year group", class: "govuk-fieldset__legend")
    expect(page).to have_element(:legend, text: "Schools I work with", class: "govuk-fieldset__legend", match: :prefer_exact)
    expect(page).to have_element(:legend, text: "School", class: "govuk-fieldset__legend", match: :prefer_exact)
  end

  def when_i_check_multiple_filters
    check "Autumn term"
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

  def and_i_see_my_selected_filters
    expect(page).to have_filter_tag("Autumn term")
    expect(page).to have_checked_field("Autumn term")
    expect(page).to have_filter_tag("Primary with mathematics")
    expect(page).to have_checked_field("Primary with mathematics")
  end

  def when_i_click_on_clear_filters
    click_on "Clear filters"
  end

  def and_i_do_not_see_any_selected_filters
    expect(page).not_to have_filter_tag("Autumn term")
    expect(page).not_to have_checked_field("Autumn term")
    expect(page).not_to have_filter_tag("Primary with mathematics")
    expect(page).not_to have_checked_field("Primary with mathematics")
  end
end
