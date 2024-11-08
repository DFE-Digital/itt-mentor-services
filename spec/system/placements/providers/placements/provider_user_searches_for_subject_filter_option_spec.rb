require "rails_helper"

RSpec.describe "Provider user searchers for a subject filter option", :js, service: :placements, type: :system do
  scenario do
    given_that_subject_filter_options_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_the_subject_filter

    when_i_search_for_primary_with_english_in_the_subject_filter
    then_i_see_primary_with_english_in_the_subject_filter
    and_i_do_not_see_primary_with_mathematics_in_the_subject_filter

    when_i_clear_the_search_in_the_subject_filter
    then_i_see_all_subjects_in_the_subject_filter
  end

  private

  def given_that_subject_filter_options_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @english_subject = create(:subject, name: "Primary with english")
    @mathematics_subject = create(:subject, name: "Primary with mathematics")
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

  def then_i_see_the_subject_filter
    expect(page).to have_element(:legend, text: "Subject", class: "govuk-fieldset__legend")
    expect(page).to have_element(:label, text: "Primary with english")
    expect(page).to have_element(:label, text: "Primary with mathematics")
  end

  def when_i_search_for_primary_with_english_in_the_subject_filter
    fill_in "Filter Subject", with: "Primary with english"
  end

  def then_i_see_primary_with_english_in_the_subject_filter
    expect(page).to have_element(:label, text: "Primary with english")
  end

  def and_i_do_not_see_primary_with_mathematics_in_the_subject_filter
    expect(page).not_to have_element(:label, text: "Primary with mathematics")
  end

  def when_i_clear_the_search_in_the_subject_filter
    fill_in "Filter Subject", with: ""
  end

  def then_i_see_all_subjects_in_the_subject_filter
    expect(page).to have_element(:label, text: "Primary with english")
    expect(page).to have_element(:label, text: "Primary with mathematics")
  end
end
