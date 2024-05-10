require "rails_helper"

RSpec.describe "Placements / Providers / Placements / Searching for a placements list",
               type: :system,
               service: :placements,
               js: true do
  let(:provider) { create(:placements_provider, name: "Provider") }
  let(:london_school) do
    create(
      :placements_school,
      name: "London School",
      latitude: 51.5072178,
      longitude: -0.1275862,
    )
  end
  let(:guildford_school) do
    create(
      :placements_school,
      name: "Guildford School",
      latitude: 51.23622,
      longitude: -0.570409,
    )
  end
  let(:bath_school) do
    create(
      :placements_school,
      name: "Bath School",
      latitude: 51.3781018,
      longitude: -2.3596827,
    )
  end
  let(:london_placement) { create(:placement, school: london_school) }
  let(:guildford_placement) { create(:placement, school: guildford_school) }
  let(:bath_placement) { create(:placement, school: bath_school) }

  before do
    london_placement
    guildford_placement
    bath_placement

    given_i_sign_in_as_patricia
  end

  context "when searching for placements near a location (London)" do
    before { stub_london_geocoder_search }

    scenario "User sees a list of placements ordered by distance, closest to the given search" do
      when_i_visit_the_placements_index_page
      and_i_fill_in_location_search_with("London")
      and_i_click_on("Search")
      then_i_see_placements_for(school_name: "London School", list_item: 0, distance: 0.0)
      and_i_see_placements_for(school_name: "Guildford School", list_item: 1, distance: 26.7)
      and_i_do_not_see_placements_for(school_name: "Bath School")
    end
  end

  context "when searching for placements near a location (Guildford)" do
    before { stub_guildford_geocoder_search }

    scenario "User sees a list of placements ordered by distance, closest to the given search" do
      when_i_visit_the_placements_index_page
      and_i_fill_in_location_search_with("Guildford")
      and_i_click_on("Search")
      then_i_see_placements_for(school_name: "Guildford School", list_item: 0, distance: 0.0)
      and_i_see_placements_for(school_name: "London School", list_item: 1, distance: 26.7)
      and_i_do_not_see_placements_for(school_name: "Bath School")
    end
  end

  context "when searching for placements using a postcode" do
    before { stub_london_geocoder_search }

    scenario "User sees a list of placements ordered by distance, closest to the given search" do
      when_i_visit_the_placements_index_page
      and_i_fill_in_location_search_with("WC1")
      and_i_click_on("Search")
      then_i_see_placements_for(school_name: "London School", list_item: 0, distance: 0.0)
      and_i_see_placements_for(school_name: "Guildford School", list_item: 1, distance: 26.7)
      and_i_do_not_see_placements_for(school_name: "Bath School")
    end
  end

  context "when searching for placements near a location, with pre-selected filters" do
    before { stub_london_geocoder_search }

    scenario "User sees a list of placements ordered by distance, closest to the given search" do
      when_i_visit_the_placements_index_page(
        {
          filters: {
            school_ids: [london_school.id],
          },
        },
      )
      and_i_fill_in_location_search_with("WC1")
      and_i_click_on("Search")
      then_i_see_placements_for(school_name: "London School", list_item: 0, distance: 0.0)
      and_i_do_not_see_placements_for(school_name: "Bath School")
      and_i_do_not_see_placements_for(school_name: "York School")
      and_i_can_see_a_preset_filter("School", "London School")
    end
  end

  private

  def given_i_sign_in_as_patricia
    user = create(:placements_user, :patricia)
    create(:user_membership, user:, organisation: provider)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def when_i_visit_the_placements_index_page(params = {})
    visit placements_provider_placements_path(provider, params)

    expect_placements_to_be_selected_in_primary_navigation
  end

  def expect_placements_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Placements", current: "page"
      expect(page).to have_link "Partner schools", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def and_i_fill_in_location_search_with(search_text)
    fill_in "search-location-field", with: search_text
  end

  def then_i_see_placements_for(school_name:, list_item:, distance:)
    within(".app-search-results") do
      placement_div = page.all(".app-search-results__item")[list_item]
      expect(placement_div).to have_content(school_name)
      expect(placement_div).to have_content("#{distance} miles")
    end
  end
  alias_method :and_i_see_placements_for, :then_i_see_placements_for

  def then_i_do_not_see_placements_for(school_name:)
    within(".app-search-results") do
      expect(page).not_to have_content(school_name)
    end
  end
  alias_method :and_i_do_not_see_placements_for, :then_i_do_not_see_placements_for

  def then_i_can_see_a_preset_filter(filter, value)
    selected_filters = page.find(".app-filter-layout__selected")

    within(selected_filters) do
      expect(page).to have_content(filter)
      expect(page).to have_content(value)
    end
  end
  alias_method :and_i_can_see_a_preset_filter, :then_i_can_see_a_preset_filter

  # Stub requests

  def stub_london_geocoder_search
    geocoder_results = instance_double("geocoder_results")
    geocoder_result = instance_double("geocoder_result")
    geocoder_results.stub(:first).and_return(geocoder_result)
    geocoder_result.stub(:coordinates).and_return([51.5072178, -0.1275862])
    allow(Geocoder).to receive(:search).and_return(geocoder_results)
  end

  def stub_guildford_geocoder_search
    geocoder_results = instance_double("geocoder_results")
    geocoder_result = instance_double("geocoder_result")
    geocoder_results.stub(:first).and_return(geocoder_result)
    geocoder_result.stub(:coordinates).and_return([51.23622, -0.570409])
    allow(Geocoder).to receive(:search).and_return(geocoder_results)
  end
end
