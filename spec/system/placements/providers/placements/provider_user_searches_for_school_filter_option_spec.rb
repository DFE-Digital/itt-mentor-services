require "rails_helper"

RSpec.describe "Provider user searchers for a school filter option", :js, service: :placements, type: :system do
  scenario do
    given_that_school_filter_options_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_the_school_filter

    when_i_search_for_hogwarts_in_the_school_filter
    then_i_see_hogwarts_in_the_school_filter
    and_i_do_not_see_springfield_elementary_in_the_school_filter

    when_i_clear_the_search_in_the_school_filter
    then_i_see_all_schools_in_the_school_filter
  end

  private

  def given_that_school_filter_options_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @primary_school = create(:placements_school, phase: "Primary", name: "Springfield Elementary")
    @secondary_school = create(:placements_school, phase: "Secondary", name: "Hogwarts")
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

  def then_i_see_the_school_filter
    expect(page).to have_element(:legend, text: "School", class: "govuk-fieldset__legend")
    expect(page).to have_element(:label, text: "Springfield Elementary")
    expect(page).to have_element(:label, text: "Hogwarts")
  end

  def when_i_search_for_hogwarts_in_the_school_filter
    fill_in "Filter School", with: "Hogwarts"
  end

  def then_i_see_hogwarts_in_the_school_filter
    expect(page).to have_element(:label, text: "Hogwarts")
  end

  def and_i_do_not_see_springfield_elementary_in_the_school_filter
    expect(page).not_to have_element(:label, text: "Springfield Elementary")
  end

  def when_i_clear_the_search_in_the_school_filter
    fill_in "Filter School", with: ""
  end

  def then_i_see_all_schools_in_the_school_filter
    expect(page).to have_element(:label, text: "Springfield Elementary")
    expect(page).to have_element(:label, text: "Hogwarts")
  end
end
