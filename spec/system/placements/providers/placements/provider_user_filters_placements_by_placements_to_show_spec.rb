require "rails_helper"

RSpec.describe "Provider user filters placements by placements to show", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_the_available_placement
    and_i_see_available_placements_is_selected_from_the_placements_to_show_filter

    when_i_select_assigned_to_me_from_the_placements_to_show_filter
    and_i_click_on_apply_filters
    then_i_see_the_placement_assigned_to_me
    and_i_see_assigned_to_me_is_selected_from_placements_to_show_filter

    when_i_select_all_placements_from_the_placements_to_show_filter
    and_i_click_on_apply_filters
    then_i_see_all_placements
    and_i_see_all_placements_is_selected_from_placements_to_show_filter
  end

  private

  def given_that_placements_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @competing_provider = build(:placements_provider, name: "Asha'man Trust")
    @primary_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary")

    @primary_maths_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    _available_placement = create(:placement, school: @primary_school, subject: @primary_maths_subject)

    @primary_english_subject = build(:subject, name: "Primary with english", subject_area: "primary")
    _unavailable_placement = create(:placement, school: @primary_school, subject: @primary_english_subject,
                                                provider: @competing_provider)

    @primary_science_subject = build(:subject, name: "Primary with science", subject_area: "primary")
    _assigned_placement = create(:placement, school: @primary_school, subject: @primary_science_subject,
                                             provider: @provider)
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

  def then_i_see_the_available_placement
    expect(page).to have_h2("Primary with mathematics – Springfield Elementary")
  end

  def and_i_see_available_placements_is_selected_from_the_placements_to_show_filter
    expect(page).to have_element(:legend, text: "Placements to show", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Available placements")
    expect(page).not_to have_checked_field("Assigned to me")
    expect(page).not_to have_checked_field("All placements")
  end

  def when_i_select_assigned_to_me_from_the_placements_to_show_filter
    choose "Assigned to me"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_placement_assigned_to_me
    expect(page).to have_h2("Primary with science – Springfield Elementary")
    expect(page).not_to have_h2("Primary with mathematics – Springfield Elementary")
    expect(page).not_to have_h2("Primary with english – Springfield Elementary")
  end

  def and_i_see_assigned_to_me_is_selected_from_placements_to_show_filter
    expect(page).to have_element(:legend, text: "Placements to show", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Assigned to me")
    expect(page).not_to have_checked_field("Available placements")
    expect(page).not_to have_checked_field("All placements")
  end

  def when_i_select_all_placements_from_the_placements_to_show_filter
    choose "All placements"
  end

  def then_i_see_all_placements
    expect(page).to have_h2("Primary with mathematics – Springfield Elementary")
    expect(page).to have_h2("Primary with science – Springfield Elementary")
    expect(page).to have_h2("Primary with english – Springfield Elementary")
  end

  def and_i_see_all_placements_is_selected_from_placements_to_show_filter
    expect(page).to have_element(:legend, text: "Placements to show", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("All placements")
    expect(page).not_to have_checked_field("Available placements")
    expect(page).not_to have_checked_field("Assigned to me")
  end
end
