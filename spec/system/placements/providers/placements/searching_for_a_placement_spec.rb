require "rails_helper"

RSpec.describe "Placements / Providers / Placements / Searching for a placements list",
               service: :placements, type: :system do
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
  let(:london_placement) { create(:placement, school: london_school, subject: build(:subject, :primary)) }
  let(:guildford_placement) { create(:placement, school: guildford_school, subject: build(:subject, :primary)) }
  let(:bath_placement) { create(:placement, school: bath_school, subject: build(:subject, :primary)) }

  before do
    london_placement
    guildford_placement
    bath_placement

    given_i_am_signed_in_as_a_placements_user(organisations: [provider])
  end

  context "when searching for placements near a location (London)" do
    before do
      stub_london_geocoder_search
      stub_routes_api_travel_time
    end

    scenario "User sees a list of placements ordered by distance, closest to the given search" do
      when_i_visit_the_placements_index_page
      and_i_fill_in_location_search_with("London")
      and_i_click_on("Apply filters")
      then_i_see_placements_for(school_name: "London School", list_item: 0, distance: 0.0)
      and_i_see_travel_times(list_item: 0, expected_travel_time: "42 minutes")
      then_i_see_placements_for(school_name: "Guildford School", list_item: 1, distance: 26.7)
      and_i_see_travel_times(list_item: 1, expected_travel_time: "42 minutes")
      and_i_do_not_see_placements_for(school_name: "Bath School")
    end
  end

  context "when searching for placements near a location (Guildford)" do
    before do
      stub_guildford_geocoder_search
      stub_routes_api_travel_time
    end

    scenario "User sees a list of placements ordered by distance, closest to the given search" do
      when_i_visit_the_placements_index_page
      and_i_fill_in_location_search_with("Guildford")
      and_i_click_on("Apply filters")
      then_i_see_placements_for(school_name: "Guildford School", list_item: 0, distance: 0.0)
      and_i_see_travel_times(list_item: 0, expected_travel_time: "42 minutes")
      then_i_see_placements_for(school_name: "London School", list_item: 1, distance: 26.7)
      and_i_see_travel_times(list_item: 1, expected_travel_time: "42 minutes")
      and_i_do_not_see_placements_for(school_name: "Bath School")
    end
  end

  context "when searching for placements using a postcode" do
    before do
      stub_london_geocoder_search
      stub_routes_api_travel_time
    end

    scenario "User sees a list of placements ordered by distance, closest to the given search" do
      when_i_visit_the_placements_index_page
      and_i_fill_in_location_search_with("WC1")
      and_i_click_on("Apply filters")
      then_i_see_placements_for(school_name: "London School", list_item: 0, distance: 0.0)
      and_i_see_travel_times(list_item: 0, expected_travel_time: "42 minutes")
      then_i_see_placements_for(school_name: "Guildford School", list_item: 1, distance: 26.7)
      and_i_see_travel_times(list_item: 1, expected_travel_time: "42 minutes")
      and_i_do_not_see_placements_for(school_name: "Bath School")
    end
  end

  context "when searching for placements near a location, with pre-selected filters" do
    before do
      stub_london_geocoder_search
      stub_routes_api_travel_time
    end

    scenario "User sees a list of placements ordered by distance, closest to the given search" do
      when_i_visit_the_placements_index_page(
        {
          filters: {
            school_ids: [london_school.id],
          },
        },
      )
      and_i_fill_in_location_search_with("WC1")
      and_i_click_on("Apply filters")
      then_i_see_placements_for(school_name: "London School", list_item: 0, distance: 0.0)
      and_i_see_travel_times(list_item: 0, expected_travel_time: "42 minutes")
      and_i_do_not_see_placements_for(school_name: "Bath School")
      and_i_do_not_see_placements_for(school_name: "York School")
      and_i_can_see_a_preset_filter("School", "London School")
    end
  end

  context "when searching for a location that doesn't exist" do
    before do
      stub_unknown_geocoder_search
      stub_routes_api_travel_time
    end

    scenario "User sees a message that no placements were found" do
      when_i_visit_the_placements_index_page
      and_i_fill_in_location_search_with("Chicken")
      and_i_click_on("Apply filters")
      then_i_see_the_empty_state
    end
  end

  private

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
      expect(page).to have_link "Schools", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def and_i_fill_in_location_search_with(search_text)
    fill_in "filters-search-location-field", with: search_text
  end

  def then_i_see_placements_for(school_name:, list_item:, distance:)
    within(".app-search-results") do
      placement_div = page.all(".app-search-results__item")[list_item]
      expect(placement_div).to have_content(school_name)
      expect(placement_div).to have_content("#{distance} miles")
    end
  end
  alias_method :and_i_see_placements_for, :then_i_see_placements_for

  def and_i_see_travel_times(list_item:, expected_travel_time:)
    within(".app-search-results") do
      placement_div = page.all(".app-search-results__item")[list_item]
      expect(placement_div).to have_content("Travel time")
      expect(placement_div).to have_content("Public transport")
      expect(placement_div).to have_content(expected_travel_time)
      expect(placement_div).to have_content("Driving")
      expect(placement_div).to have_content(expected_travel_time)
      expect(placement_div).to have_content("Walking")
      expect(placement_div).to have_content(expected_travel_time)
    end
  end

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

  def then_i_see_the_empty_state
    expect(page).to have_content I18n.t("placements.providers.placements.index.no_results")
  end

  # Stub requests

  def stub_london_geocoder_search
    geocoder_results = instance_double("geocoder_results")
    geocoder_result = instance_double("geocoder_result")
    allow(geocoder_results).to receive(:first).and_return(geocoder_result)
    allow(geocoder_result).to receive(:coordinates).and_return([51.5072178, -0.1275862])
    allow(Geocoder).to receive(:search).and_return(geocoder_results)
  end

  def stub_guildford_geocoder_search
    geocoder_results = instance_double("geocoder_results")
    geocoder_result = instance_double("geocoder_result")
    allow(geocoder_results).to receive(:first).and_return(geocoder_result)
    allow(geocoder_result).to receive(:coordinates).and_return([51.23622, -0.570409])
    allow(Geocoder).to receive(:search).and_return(geocoder_results)
  end

  def stub_unknown_geocoder_search
    geocoder_results = instance_double("geocoder_results")
    geocoder_result = instance_double("geocoder_result")
    allow(geocoder_results).to receive(:first).and_return(geocoder_result)
    allow(geocoder_result).to receive(:coordinates).and_return([55.378051, -3.435973])
    allow(Geocoder).to receive(:search).and_return(geocoder_results)
  end

  def stub_routes_api_travel_time
    body = [
      {
        "destinationIndex" => 0,
        "localizedValues" => {
          "distance" => { "text" => "20 mi" },
          "duration" => { "text" => "42 mins" },
          "staticDuration" => { "text" => "36 mins" },
        },
      },
      {
        "destinationIndex" => 1,
        "localizedValues" => {
          "distance" => { "text" => "20 mi" },
          "duration" => { "text" => "42 mins" },
          "staticDuration" => { "text" => "36 mins" },
        },
      },
    ].to_json

    stub_request(:post, "https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix").to_return(status: 200, body:, headers: { "Content-Type" => "application/json" })
  end
end
