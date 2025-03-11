require "rails_helper"

RSpec.describe "Provider user filters schools by trained_mentors", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_the_provider_find_a_school_feature_is_enabled
    and_i_am_signed_in

    when_i_navigate_to_the_find_index_page
    then_i_am_on_the_find_index_page
    and_i_see_all_schools
    and_i_see_the_trained_mentors_filter

    when_i_select_yes_from_the_trained_mentors_filter
    and_i_click_on_apply_filters
    then_i_see_springfield_elementary
    and_i_do_not_see_springfield_high
    and_i_see_my_selected_trained_mentor_filter

    when_i_select_no_from_the_trained_mentors_filter
    and_i_click_on_apply_filters
    then_i_see_all_schools
    and_i_see_my_selected_trained_mentor_filters

    when_i_click_on_the_no_trained_mentor_filter_tag
    then_i_see_springfield_elementary
    and_i_do_not_see_springfield_high
    and_i_do_not_see_the_no_trained_mentor_filter

    when_i_click_on_the_yes_trained_mentor_filter_tag
    then_i_see_all_schools
    and_i_do_not_see_any_selected_trained_mentor_filters
  end

  private

  def given_that_schools_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")

    @primary_trained_mentor = build(:placements_mentor, trained: true)
    @primary_school = create(:placements_school, phase: "Primary", name: "Springfield Elementary", mentors: [@primary_trained_mentor])

    @secondary_untrained_mentor = build(:placements_mentor, trained: false)
    @secondary_school = build(:placements_school, phase: "Secondary", name: "Springfield High", mentors: [@secondary_untrained_mentor])
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def and_the_provider_find_a_school_feature_is_enabled
    Flipper.enable(:provider_find_a_school)
  end

  def when_i_navigate_to_the_find_index_page
    within ".app-primary-navigation__nav" do
      click_on "Find"
    end
  end

  def then_i_am_on_the_find_index_page
    expect(page).to have_title("Find schools and placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Find schools and placements")
    expect(page).to have_h2("Filter")
  end

  def then_i_see_all_schools
    expect(page).to have_h2("Springfield Elementary")
    expect(page).to have_h2("Springfield High")
  end

  alias_method :and_i_see_all_schools, :then_i_see_all_schools

  def and_i_see_the_trained_mentors_filter
    expect(page).to have_element(:legend, text: "Trained mentors", class: "govuk-fieldset__legend")
    expect(page).to have_field("Yes", type: :checkbox, unchecked: true)
    expect(page).to have_field("No", type: :checkbox, unchecked: true)
  end

  def when_i_select_yes_from_the_trained_mentors_filter
    check "Yes"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_springfield_elementary
    expect(page).to have_h2("Springfield Elementary")
  end

  def and_i_do_not_see_springfield_high
    expect(page).not_to have_h2("Springfield high")
  end

  def and_i_see_my_selected_trained_mentor_filter
    expect(page).to have_filter_tag("Yes")
    expect(page).to have_checked_field("Yes")
    expect(page).not_to have_filter_tag("No")
    expect(page).not_to have_checked_field("No")
  end

  def when_i_select_no_from_the_trained_mentors_filter
    check "No"
  end

  def and_i_see_my_selected_trained_mentor_filters
    expect(page).to have_filter_tag("Yes")
    expect(page).to have_checked_field("Yes")
    expect(page).to have_filter_tag("No")
    expect(page).to have_checked_field("No")
  end

  def when_i_click_on_the_yes_trained_mentor_filter_tag
    within ".app-filter-tags" do
      click_on "Yes"
    end
  end

  def then_i_see_springfield_high
    expect(page).to have_h2("Springfield High")
  end

  def and_i_do_not_see_springfield_elementary
    expect(page).not_to have_h2("Springfield Elementary")
  end

  def and_i_do_not_see_the_yes_trained_mentor_filter
    expect(page).not_to have_filter_tag("Yes")
    expect(page).not_to have_checked_field("Yes")
    expect(page).to have_filter_tag("No")
    expect(page).to have_checked_field("No")
  end

  def when_i_click_on_the_no_trained_mentor_filter_tag
    within ".app-filter-tags" do
      click_on "No"
    end
  end

  def and_i_do_not_see_the_no_trained_mentor_filter
    expect(page).not_to have_filter_tag("No")
    expect(page).not_to have_checked_field("No")
  end

  def and_i_do_not_see_any_selected_trained_mentor_filters
    expect(page).not_to have_filter_tag("Yes")
    expect(page).not_to have_checked_field("Yes")
    expect(page).not_to have_filter_tag("No")
    expect(page).not_to have_checked_field("No")
  end
end
