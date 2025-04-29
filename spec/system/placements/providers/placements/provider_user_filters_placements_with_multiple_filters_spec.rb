require "rails_helper"

RSpec.describe "Provider user filters placements with multiple filters", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_navigate_to_the_placements_index_page
    then_i_am_on_the_placements_index_page
    and_i_see_all_placements
    and_i_see_all_filters

    when_i_check_multiple_filters
    and_i_click_on_apply_filters
    then_i_see_the_english_placement
    and_i_do_not_see_the_primary_with_maths_placement
    and_i_see_my_selected_filters

    when_i_click_on_clear_filters
    then_i_see_all_placements
    and_i_do_not_see_any_selected_filters
  end

  private

  def given_that_placements_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")
    @secondary_school = build(:placements_school, phase: "Secondary", name: "Hogwarts")
    @autumn_term = build(:placements_term, :autumn)

    @primary_maths_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    _primary_maths_placement = create(:placement, school: @primary_school, subject: @primary_maths_subject,
                                                  terms: [@autumn_term], provider: @provider, academic_year: Placements::AcademicYear.current.next)

    @secondary_english_subject = build(:subject, name: "English", subject_area: "secondary")
    _secondary_english_placement = create(:placement, school: @secondary_school, subject: @secondary_english_subject,
                                                      terms: [@autumn_term], provider: @provider, academic_year: Placements::AcademicYear.current.next)
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def when_i_navigate_to_the_placements_index_page
    within ".app-primary-navigation__nav" do
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
      "Expected date" => "Autumn term",
      "School" => "Springfield Elementary",
    })

    expect(page).to have_table_row({
      "Subject" => "English",
      "Expected date" => "Autumn term",
      "School" => "Hogwarts",
    })
  end
  alias_method :then_i_see_all_placements, :and_i_see_all_placements

  def and_i_see_all_filters
    expect(page).to have_element(:legend, text: "Phase", class: "govuk-fieldset__legend")
    expect(page).to have_element(:legend, text: "Subject", class: "govuk-fieldset__legend")
    expect(page).to have_element(:legend, text: "School", class: "govuk-fieldset__legend", match: :prefer_exact)
  end

  def when_i_check_multiple_filters
    check "Hogwarts"
    check "English"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_english_placement
    expect(page).to have_table_row({
      "Subject" => "English",
      "Expected date" => "Autumn term",
      "School" => "Hogwarts",
    })
  end

  def and_i_do_not_see_the_primary_with_maths_placement
    expect(page).not_to have_table_row({
      "Subject" => "Primary with mathematics",
      "Expected date" => "Autumn term",
      "School" => "Springfield Elementary",
    })
  end

  def and_i_see_my_selected_filters
    expect(page).to have_filter_tag("Hogwarts")
    expect(page).to have_checked_field("Hogwarts")
    expect(page).to have_filter_tag("English")
    expect(page).to have_checked_field("English")
  end

  def when_i_click_on_clear_filters
    click_on "Clear filters"
  end

  def and_i_do_not_see_any_selected_filters
    expect(page).not_to have_filter_tag("Hogwarts")
    expect(page).not_to have_checked_field("Hogwarts")
    expect(page).not_to have_filter_tag("English")
    expect(page).not_to have_checked_field("English")
  end
end
