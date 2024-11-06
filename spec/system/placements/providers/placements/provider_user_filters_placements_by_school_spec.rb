require "rails_helper"

RSpec.describe "Provider user filters placements by school", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_all_placements
    and_i_see_the_school_filter

    when_i_select_springfield_elementary_from_the_school_filter
    and_i_click_on_apply_filters
    then_i_see_the_springfield_elementary_placement
    and_i_do_not_see_the_hogwarts_placement
    and_i_see_the_spring_field_elementary_selected_school_filter

    when_i_select_hogwarts_from_the_school_filter
    and_i_click_on_apply_filters
    then_i_see_all_placements
    and_i_see_my_selected_school_filters

    when_i_click_on_the_springfield_elementary_school_filter_tag
    then_i_see_the_hogwarts_placement
    and_i_do_not_see_the_springfield_elementary_placement
    and_i_do_not_see_the_springfield_elementary_selected_school_filter

    when_i_click_on_the_hogwarts_school_filter_tag
    then_i_see_all_placements
    and_i_do_not_see_any_selected_school_filters
  end

  private

  def given_that_placements_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")

    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")
    @primary_maths_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    _primary_placement = create(:placement, school: @primary_school, subject: @primary_maths_subject)

    @secondary_school = build(:placements_school, phase: "Secondary", name: "Hogwarts")
    @secondary_english_subject = build(:subject, name: "English", subject_area: "secondary")
    _secondary_placement = create(:placement, school: @secondary_school, subject: @secondary_english_subject)
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
    expect(page).to have_h2("English – Hogwarts")
  end

  def and_i_see_the_school_filter
    expect(page).to have_element(:legend, text: "School", class: "govuk-fieldset__legend")
    expect(page).to have_field("Springfield Elementary", type: "checkbox", checked: false)
    expect(page).to have_field("Hogwarts", type: "checkbox", checked: false)
  end

  def when_i_select_springfield_elementary_from_the_school_filter
    check "Springfield Elementary"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_springfield_elementary_placement
    expect(page).to have_h2("Primary with mathematics – Springfield Elementary")
  end

  def and_i_do_not_see_the_hogwarts_placement
    expect(page).not_to have_h2("English – Hogwarts")
  end

  def and_i_see_the_spring_field_elementary_selected_school_filter
    expect(page).to have_filter_tag("Springfield Elementary")
    expect(page).to have_checked_field("Springfield Elementary")
    expect(page).not_to have_checked_field("Hogwarts")
    expect(page).not_to have_filter_tag("Hogwarts")
  end

  def when_i_select_hogwarts_from_the_school_filter
    check "Hogwarts"
  end

  def and_i_see_my_selected_school_filters
    expect(page).to have_filter_tag("Springfield Elementary")
    expect(page).to have_checked_field("Springfield Elementary")
    expect(page).to have_filter_tag("Hogwarts")
    expect(page).to have_checked_field("Hogwarts")
  end

  def when_i_click_on_the_springfield_elementary_school_filter_tag
    within ".app-filter-tags" do
      click_on "Springfield Elementary"
    end
  end

  def then_i_see_the_hogwarts_placement
    expect(page).to have_h2("English – Hogwarts")
  end

  def and_i_do_not_see_the_springfield_elementary_placement
    expect(page).not_to have_h2("Primary with mathematics – Springfield Elementary")
  end

  def and_i_do_not_see_the_springfield_elementary_selected_school_filter
    expect(page).not_to have_filter_tag("Springfield Elementary")
    expect(page).not_to have_checked_field("Springfield Elementary")
  end

  def when_i_click_on_the_hogwarts_school_filter_tag
    within ".app-filter-tags" do
      click_on "Hogwarts"
    end
  end

  def and_i_do_not_see_any_selected_school_filters
    expect(page).not_to have_filter_tag("Springfield Elementary")
    expect(page).not_to have_checked_field("Springfield Elementary")
    expect(page).not_to have_filter_tag("Hogwarts")
    expect(page).not_to have_checked_field("Hogwarts")
  end
end
