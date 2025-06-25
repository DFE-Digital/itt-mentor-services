require "rails_helper"

RSpec.describe "Provider user filters schools by SEND placements", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_all_schools
    and_i_see_the_send_placement_filter

    when_i_select_show_only_schools_with_sends_specific_placements_filter
    and_i_click_on_apply_filters
    then_i_see_the_springfield_elementary_school
    and_i_do_not_see_the_hogwarts_elementary_school
    and_i_see_my_selected_show_only_schools_with_sends_specific_placements_filter

    when_i_click_on_the_show_only_schools_with_sends_specific_placements_filter_tag
    then_i_see_all_schools
    and_i_do_not_see_the_show_only_schools_with_sends_specific_placements_filter_tag
  end

  private

  def given_that_schools_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")

    @primary_school_with_send_placement = build(:placements_school, phase: "Primary", name: "Springfield Elementary", partner_providers: [@provider])
    key_stage_1 = build(:key_stage, name: "Key stage 1")
    _send_placement = create(:placement, :send, key_stage: key_stage_1, school: @primary_school_with_send_placement)

    @primary_school_without_send_placement = build(:placements_school, phase: "Primary", name: "Hogwarts Elementary", partner_providers: [@provider])
    @primary_subject = build(:subject, name: "Primary", subject_area: "primary")
    _primary_placement = create(:placement, school: @primary_school_without_send_placement, subject: @primary_subject)
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

  def and_i_see_the_send_placement_filter
    expect(page).to have_element(:legend, text: "SEND placements", class: "govuk-fieldset__legend")
    expect(page).to have_field(
      "Show only schools with SEND specific placements",
      type: :checkbox,
      unchecked: true,
    )
  end

  def when_i_select_show_only_schools_with_sends_specific_placements_filter
    check "Show only schools with SEND specific placements"
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

  def and_i_see_my_selected_show_only_schools_with_sends_specific_placements_filter
    expect(page).to have_filter_tag("Show only schools with SEND specific placements")
    expect(page).to have_checked_field("Show only schools with SEND specific placements")
  end

  def when_i_click_on_the_show_only_schools_with_sends_specific_placements_filter_tag
    within ".app-filter-tags" do
      click_on "Show only schools with SEND specific placements"
    end
  end

  def and_i_do_not_see_the_show_only_schools_with_sends_specific_placements_filter_tag
    expect(page).not_to have_filter_tag("Show only schools with SEND specific placements")
    expect(page).not_to have_checked_field("Show only schools with SEND specific placements")
  end
end
