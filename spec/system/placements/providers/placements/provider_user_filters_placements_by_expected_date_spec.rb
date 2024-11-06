require "rails_helper"

RSpec.describe "Provider user filters placements by expected date", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_all_placements
    and_i_see_the_expected_date_filter

    when_i_select_autumn_term_from_the_expected_date_filter
    and_i_click_on_apply_filters
    then_i_see_the_autumn_term_placement
    and_i_do_not_see_the_spring_term_placement
    and_i_see_my_selected_expected_date_filter

    when_i_select_spring_term_from_the_expected_date_filter
    and_i_click_on_apply_filters
    then_i_see_all_placements
    and_i_see_my_selected_expected_date_filters

    when_i_click_on_the_autumn_term_expected_date_filter_tag
    then_i_see_the_spring_term_placement
    and_i_do_not_see_the_autumn_term_placement
    and_i_do_not_see_the_autumn_term_selected_expected_date_filters

    when_i_click_on_the_spring_term_expected_date_filter_tag
    then_i_see_all_placements
    and_i_do_not_see_any_selected_expected_date_filters
  end

  private

  def given_that_placements_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")

    @autumn_term = build(:placements_term, :autumn)
    @primary_maths_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    _autumn_term_placement = create(:placement, school: @primary_school, subject: @primary_maths_subject,
                                                terms: [@autumn_term])

    @spring_term = build(:placements_term, :spring)
    @primary_english_subject = build(:subject, name: "Primary with english", subject_area: "primary")
    _spring_term_placement = create(:placement, school: @primary_school, subject: @primary_english_subject,
                                                terms: [@spring_term])
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

  def and_i_see_the_expected_date_filter
    expect(page).to have_element(:legend, text: "Expected date", class: "govuk-fieldset__legend")
    expect(page).to have_field("Autumn term", type: "checkbox", checked: false)
    expect(page).to have_field("Spring term", type: "checkbox", checked: false)
  end

  def when_i_select_autumn_term_from_the_expected_date_filter
    check "Autumn term"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_autumn_term_placement
    expect(page).to have_h2("Primary with mathematics – Springfield Elementary")
  end

  def and_i_do_not_see_the_spring_term_placement
    expect(page).not_to have_h2("Primary with english – Springfield Elementar")
  end

  def and_i_see_my_selected_expected_date_filter
    expect(page).to have_filter_tag("Autumn term")
    expect(page).to have_checked_field("Autumn term")
    expect(page).not_to have_checked_field("Spring term")
    expect(page).not_to have_filter_tag("Spring term")
  end

  def when_i_select_spring_term_from_the_expected_date_filter
    check "Spring term"
  end

  def and_i_see_my_selected_expected_date_filters
    expect(page).to have_filter_tag("Autumn term")
    expect(page).to have_checked_field("Autumn term")
    expect(page).to have_filter_tag("Spring term")
    expect(page).to have_checked_field("Spring term")
  end

  def when_i_click_on_the_autumn_term_expected_date_filter_tag
    within ".app-filter-tags" do
      click_on "Autumn term"
    end
  end

  def then_i_see_the_spring_term_placement
    expect(page).to have_h2("Primary with english – Springfield Elementary")
  end

  def and_i_do_not_see_the_autumn_term_placement
    expect(page).not_to have_h2("Primary with mathematics – Springfield Elementary")
  end

  def and_i_do_not_see_the_autumn_term_selected_expected_date_filters
    expect(page).not_to have_filter_tag("Autumn term")
    expect(page).not_to have_checked_field("Autumn term")
    expect(page).to have_filter_tag("Spring term")
    expect(page).to have_checked_field("Spring term")
  end

  def when_i_click_on_the_spring_term_expected_date_filter_tag
    within ".app-filter-tags" do
      click_on "Spring term"
    end
  end

  def and_i_do_not_see_any_selected_expected_date_filters
    expect(page).not_to have_filter_tag("Autumn term")
    expect(page).not_to have_checked_field("Autumn term")
    expect(page).not_to have_filter_tag("Spring term")
    expect(page).not_to have_checked_field("Spring term")
  end
end
