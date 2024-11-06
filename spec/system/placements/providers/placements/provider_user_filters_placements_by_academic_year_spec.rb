require "rails_helper"

RSpec.describe "Provider user filters placements by academic year", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_the_placement_for_the_current_academic_year
    and_i_see_this_year_is_selected_from_the_academic_year_filter

    when_i_select_next_year_from_the_academic_year_filter
    and_i_click_on_apply_filters
    then_i_see_the_placement_for_the_next_academic_year
    and_i_do_not_see_the_placement_for_the_current_academic_year
    and_i_see_next_year_is_selected_from_the_academic_year_filter

    when_i_select_this_year_from_the_academic_year_filter
    and_i_click_on_apply_filters
    then_i_see_the_placement_for_the_current_academic_year
    and_i_see_this_year_is_selected_from_the_academic_year_filter
  end

  private

  def given_that_placements_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")
    @current_academic_year = Placements::AcademicYear.current
    @next_academic_year = @current_academic_year.next

    @primary_maths_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    _current_academic_year_placement = create(:placement, school: @primary_school, subject: @primary_maths_subject,
                                                          academic_year: @current_academic_year)

    @primary_english_subject = build(:subject, name: "Primary with english", subject_area: "primary")
    _next_academic_year_placement = create(:placement, school: @primary_school, subject: @primary_english_subject,
                                                       academic_year: @next_academic_year)
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

  def then_i_see_the_placement_for_the_current_academic_year
    expect(page).to have_h2("Primary with mathematics – Springfield Elementary")
  end

  def when_i_select_next_year_from_the_academic_year_filter
    choose "Next year (#{@next_academic_year.name})"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_placement_for_the_next_academic_year
    expect(page).to have_h2("Primary with english – Springfield Elementary")
  end

  def and_i_do_not_see_the_placement_for_the_current_academic_year
    expect(page).not_to have_h2("Primary with mathematics – Springfield Elementary")
  end

  def and_i_see_next_year_is_selected_from_the_academic_year_filter
    expect(page).to have_element(:legend, text: "Academic year", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Next year (#{@next_academic_year.name})")
    expect(page).not_to have_checked_field("This year (#{@current_academic_year.name})")
  end

  def when_i_select_this_year_from_the_academic_year_filter
    choose "This year (#{@current_academic_year.name})"
  end

  def and_i_see_this_year_is_selected_from_the_academic_year_filter
    expect(page).to have_element(:legend, text: "Academic year", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("This year (#{@current_academic_year.name})")
    expect(page).not_to have_checked_field("Next year (#{@next_academic_year.name})")
  end
end
