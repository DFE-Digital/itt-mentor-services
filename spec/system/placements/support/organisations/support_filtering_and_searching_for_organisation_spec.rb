require "rails_helper"

RSpec.describe "Support user filters and searches for organisations", type: :system, service: :placements do
  before do
    given_i_am_signed_in_as_a_support_user
    and_placement_schools_and_providers_exist
    then_i_see_support_navigation_with_organisation_selected
  end

  after { Capybara.app_host = nil }

  scenario "Support user filters and gets results" do
    when_i_filter_by(["Lead partner"])
    then_i_see_only_the_organisation_with_lead_partner_as_provider_type
    when_i_clear_filters
    then_i_see_all_organisations
  end

  scenario "Support user filters and gets NO results" do
    when_i_filter_by(%w[SCITT])
    then_i_see_the_no_results_message("There are no results for the selected filter.")
    when_i_clear_filters
    then_i_see_all_organisations
  end

  scenario "Support user searches and gets results" do
    when_i_search_by("HA4")
    then_i_see_organisations_matching_the_postcode_search
    when_i_clear_search
    then_i_see_all_organisations
  end

  scenario "Support user searches and gets NO results" do
    when_i_search_by("BLAH")
    then_i_see_the_no_results_message("There are no results for 'BLAH'.")
    when_i_clear_search
    then_i_see_all_organisations
  end

  scenario "Support user filters THEN searches with results" do
    when_i_filter_by(%w[School])
    when_i_search_by("London")
    then_i_see_the_london_school_only
    when_i_clear_search
    then_i_see_all_schools
    when_i_clear_filters
    then_i_see_all_organisations
  end

  scenario "Support user searches THEN filters with results" do
    when_i_search_by("London")
    when_i_filter_by(%w[School])
    then_i_see_the_london_school_only
    when_i_clear_filters
    then_i_see_all_london_organisations
    when_i_clear_search
    then_i_see_all_organisations
  end

  scenario "Support user searches and filters without results" do
    when_i_search_by("London")
    when_i_filter_by(%w[University])
    then_i_see_the_no_results_message("There are no results for 'London' and the selected filter.")
  end

  scenario "Clear individual filters" do
    when_i_filter_by(["School", "SCITT", "University", "Lead partner"])
    then_i_see_the_selections_in_filter_list
    then_i_see_all_organisations
    when_i_clear_school_filter
    then_the_other_filters_remain_in_filter_list
    and_i_do_not_see_schools
  end

  private

  def when_i_filter_by(filters)
    filters.each { |filter| check filter }
    click_on "Apply filters"
  end

  def when_i_search_by(search)
    fill_in "Search by organisation name or postcode", with: search
    click_on "Search"
  end

  def when_i_clear_search
    click_on "Clear search"
  end

  def then_i_see_organisations_matching_the_postcode_search
    expect(page).to have_content("A School")
    expect(page).to have_content("University of Westminster")

    expect(page).not_to have_content("Lead Partner London")
    expect(page).not_to have_content("School London")
    expect(page).not_to have_content("1 Primary")
  end

  def then_i_see_only_the_organisation_with_lead_partner_as_provider_type
    expect(page).to have_content("Lead Partner London")

    expect(page).not_to have_content("School London")
    expect(page).not_to have_content("University of Westminster")
    expect(page).not_to have_content("A School")
    expect(page).not_to have_content("1 Primary")
  end

  def then_i_see_the_no_results_message(message)
    expect(page).to have_content message
  end

  def when_i_clear_filters
    click_on "Clear filters"
  end

  def then_i_see_the_selections_in_filter_list
    within(".app-filter-tags") do
      expect(page).to have_content "Lead partner"
      expect(page).to have_content "School"
      expect(page).to have_content "SCITT"
      expect(page).to have_content "University"
    end
  end

  def when_i_clear_school_filter
    within(".app-filter-tags") do
      click_on "School"
    end
  end

  def then_the_other_filters_remain_in_filter_list
    within(".app-filter-tags") do
      expect(page).to have_content "Lead partner"
      expect(page).to have_content "SCITT"
      expect(page).to have_content "University"

      expect(page).not_to have_content "School"
    end
  end

  def and_i_do_not_see_schools
    expect(page).to have_content("University of Westminster")
    expect(page).to have_content("Lead Partner London")

    expect(page).not_to have_content("School London")
    expect(page).not_to have_content("A School")
    expect(page).not_to have_content("1 Primary")
  end

  def then_i_see_all_organisations
    expect(page).to have_content("School London")
    expect(page).to have_content("University of Westminster")
    expect(page).to have_content("Lead Partner London")
    expect(page).to have_content("A School")
    expect(page).to have_content("1 Primary")
  end

  def then_i_see_the_london_school_only
    expect(page).to have_content("School London")

    expect(page).not_to have_content("University of Westminster")
    expect(page).not_to have_content("Lead Partner London")
    expect(page).not_to have_content("A School")
    expect(page).not_to have_content("1 Primary")
  end

  def then_i_see_all_london_organisations
    expect(page).to have_content("School London")
    expect(page).to have_content("Lead Partner London")

    expect(page).not_to have_content("University of Westminster")
    expect(page).not_to have_content("A School")
    expect(page).not_to have_content("1 Primary")
  end

  def then_i_see_all_schools
    expect(page).to have_content("School London")
    expect(page).to have_content("1 Primary")
    expect(page).to have_content("A School")

    expect(page).not_to have_content("University of Westminster")
    expect(page).not_to have_content("Lead Partner London")
  end

  def given_i_am_signed_in_as_a_support_user
    user = create(:placements_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Start now"
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisations", current: "page"
      expect(page).to have_link "Users", current: "false"
    end
  end

  def and_placement_schools_and_providers_exist
    create(:school, :placements, name: "School London", postcode: "EC12 5BN")
    create(:placements_provider, :university, name: "University of Westminster", postcode: "HA4 9JZ")
    create(:placements_provider, :lead_school, name: "Lead Partner London", postcode: "SE3 5SL")
    create(:school, :placements, name: "A School", postcode: "HA4 2FW")
    create(:school, :placements, name: "1 Primary", postcode: "SW12 H3B")
  end
end
