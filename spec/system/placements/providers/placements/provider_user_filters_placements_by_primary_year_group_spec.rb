require "rails_helper"

RSpec.describe "Provider user filters placements by primary year group", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_all_placements
    and_i_see_the_primary_year_group_filter

    when_i_select_nursery_term_from_the_primary_year_group_filter
    and_i_click_on_apply_filters
    then_i_see_the_nursery_placement
    and_i_do_not_see_the_year_1_placement
    and_i_see_my_selected_primary_year_group_filter

    when_i_select_year_1_from_the_primary_year_group_filter
    and_i_click_on_apply_filters
    then_i_see_all_placements
    and_i_see_my_selected_primary_year_group_filters

    when_i_click_on_the_nursery_primary_year_group_filter_tag
    then_i_see_the_year_1_placement
    and_i_do_not_see_the_nursery_placement
    and_i_do_not_see_the_nursery_selected_primary_year_group_filters

    when_i_click_on_the_year_1_primary_year_group_filter_tag
    then_i_see_all_placements
    and_i_do_not_see_any_selected_primary_year_group_filters
  end

  private

  def given_that_placements_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")

    @primary_maths_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    _nursery_placement = create(:placement, school: @primary_school, subject: @primary_maths_subject,
                                            year_group: :nursery)

    @primary_english_subject = build(:subject, name: "Primary with english", subject_area: "primary")
    _year_1_placement = create(:placement, school: @primary_school, subject: @primary_english_subject,
                                           year_group: :year_1)
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
    expect(page).to have_h2("Primary with mathematics (Nursery) – Springfield Elementary")
    expect(page).to have_h2("Primary with english (Year 1) – Springfield Elementary")
  end

  def and_i_see_the_primary_year_group_filter
    expect(page).to have_element(:legend, text: "Primary year group", class: "govuk-fieldset__legend")
    expect(page).to have_field("Nursery", type: "checkbox", checked: false)
    expect(page).to have_field("Reception", type: "checkbox", checked: false)
    expect(page).to have_field("Year 1", type: "checkbox", checked: false)
  end

  def when_i_select_nursery_term_from_the_primary_year_group_filter
    check "Nursery"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_nursery_placement
    expect(page).to have_h2("Primary with mathematics (Nursery) – Springfield Elementary")
  end

  def and_i_do_not_see_the_year_1_placement
    expect(page).not_to have_h2("Primary with english (Year 1) – Springfield Elementary")
  end

  def and_i_see_my_selected_primary_year_group_filter
    expect(page).to have_filter_tag("Nursery")
    expect(page).to have_checked_field("Nursery")
    expect(page).not_to have_filter_tag("Year 1")
    expect(page).not_to have_checked_field("Year 1")
  end

  def when_i_select_year_1_from_the_primary_year_group_filter
    check "Year 1"
  end

  def and_i_see_my_selected_primary_year_group_filters
    expect(page).to have_filter_tag("Nursery")
    expect(page).to have_checked_field("Nursery")
    expect(page).to have_filter_tag("Year 1")
    expect(page).to have_checked_field("Year 1")
  end

  def when_i_click_on_the_nursery_primary_year_group_filter_tag
    within ".app-filter-tags" do
      click_on "Nursery"
    end
  end

  def then_i_see_the_year_1_placement
    expect(page).to have_h2("Primary with english (Year 1) – Springfield Elementary")
  end

  def and_i_do_not_see_the_nursery_placement
    expect(page).not_to have_h2("Primary with mathematics (Nursery) – Springfield Elementary")
  end

  def and_i_do_not_see_the_nursery_selected_primary_year_group_filters
    expect(page).not_to have_filter_tag("Nursery")
    expect(page).not_to have_checked_field("Nursery")
    expect(page).to have_filter_tag("Year 1")
    expect(page).to have_checked_field("Year 1")
  end

  def when_i_click_on_the_year_1_primary_year_group_filter_tag
    within ".app-filter-tags" do
      click_on "Year 1"
    end
  end

  def and_i_do_not_see_any_selected_primary_year_group_filters
    expect(page).not_to have_filter_tag("Nursery")
    expect(page).not_to have_checked_field("Nursery")
    expect(page).not_to have_filter_tag("Year 1")
    expect(page).not_to have_checked_field("Year 1")
  end
end
