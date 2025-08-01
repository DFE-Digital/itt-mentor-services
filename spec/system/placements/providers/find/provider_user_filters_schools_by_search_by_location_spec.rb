require "rails_helper"

RSpec.describe "Provider user filters schools by search by location", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_all_schools
    and_i_see_the_search_by_location_filter

    when_i_search_for_schools_near_guildford
    and_i_click_on_apply_filters
    then_i_see_the_guildford_school
    and_i_do_not_see_the_bath_school
    and_i_see_the_guildford_search_by_location_filter

    when_i_search_for_schools_in_a_made_up_location
    and_i_click_on_apply_filters
    then_i_see_no_schools
    and_i_see_my_made_up_location_search_by_location_filter
    and_i_do_not_see_my_guildford_search_by_location_filter

    when_i_click_on_the_made_up_location_search_by_location_filter_tag
    then_i_see_all_schools
    and_i_do_not_see_any_selected_search_by_location_filters
  end

  private

  def given_that_schools_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")
    @guildford_school = create(:placements_school, phase: "Primary", name: "Springfield Elementary", latitude: 51.23622,
                                                   longitude: -0.570409, hosting_interests: [build(:hosting_interest, appetite: "actively_looking", academic_year: Placements::AcademicYear.current)])
    @bath_school = create(:placements_school, phase: "Secondary", name: "Hogwarts", latitude: 51.3781018,
                                              longitude: -2.3596827, hosting_interests: [build(:hosting_interest, appetite: "actively_looking", academic_year: Placements::AcademicYear.current)])

    stub_geocoder_results
    stub_routes_request
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def when_i_navigate_to_the_find_schools_page
    within primary_navigation do
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
    expect(page).to have_h2("Hogwarts")
  end

  def and_i_see_the_search_by_location_filter
    expect(page).to have_field("Enter a town, city or postcode", type: :search)
    expect(page).to have_element(:p, text: "Powered by Google", class: "govuk-body-s secondary-text")
  end

  def when_i_search_for_schools_near_guildford
    fill_in "Enter a town, city or postcode", with: "Guildford"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_guildford_school
    expect(page).to have_h2("Springfield Elementary")
    expect(page).to have_result_detail_row("Distance", "0.0 mi")
    expect(page).to have_result_detail_row("Travel time", "42 minutes by public transport, 42 minutes drive, 42 minutes walk")
  end

  def and_i_do_not_see_the_bath_school
    expect(page).not_to have_h2("Hogwarts")
  end

  def and_i_see_the_guildford_search_by_location_filter
    expect(page).to have_filter_tag("Guildford")
    expect(page).to have_field("Enter a town, city or postcode", type: :search, with: "Guildford")
  end

  def when_i_search_for_schools_in_a_made_up_location
    fill_in "Enter a town, city or postcode", with: "Mordor"
  end

  def then_i_see_no_schools
    expect(page).to have_h2("No schools")
    expect(page).to have_element(:p, text: "There are no schools that match your selection. Try searching again, or removing one or more filters.")
  end

  def and_i_see_my_made_up_location_search_by_location_filter
    expect(page).to have_filter_tag("Mordor")
    expect(page).to have_field("Enter a town, city or postcode", type: :search, with: "Mordor")
  end

  def and_i_do_not_see_my_guildford_search_by_location_filter
    expect(page).not_to have_filter_tag("Guildford")
    expect(page).not_to have_field("Enter a town, city or postcode", type: :search, with: "Guildford")
  end

  def when_i_click_on_the_made_up_location_search_by_location_filter_tag
    within ".app-filter-tags" do
      click_on "Mordor"
    end
  end

  def and_i_do_not_see_any_selected_search_by_location_filters
    expect(page).not_to have_filter_tag("Guildford")
    expect(page).not_to have_field("Enter a town, city or postcode", type: :search, with: "Guildford")
    expect(page).not_to have_result_detail_row("Distance", "0.0 mi")
    expect(page).not_to have_result_detail_row("Travel time", "42 minutes by public transport, 42 minutes drive, 42 minutes walk")
  end

  def then_i_see_all_schools
    expect(page).to have_h2("Springfield Elementary")
    expect(page).to have_h2("Hogwarts")
  end

  def stub_geocoder_results
    guildford_geocoder_results = instance_double("geocoder_results")
    guildford_geocoder_result = instance_double("geocoder_result")
    allow(guildford_geocoder_results).to receive(:first).and_return(guildford_geocoder_result)
    allow(guildford_geocoder_result).to receive(:coordinates).and_return([51.23622, -0.570409])

    mordor_geocoder_results = instance_double("geocoder_results")
    mordor_geocoder_result = instance_double("geocoder_result")
    allow(mordor_geocoder_results).to receive(:first).and_return(mordor_geocoder_result)
    allow(mordor_geocoder_result).to receive(:coordinates).and_return([55.378051, -3.435973])

    allow(Geocoder).to receive(:search).and_return(guildford_geocoder_results, mordor_geocoder_results)
  end

  def stub_routes_request
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

    stub_request(:post, "https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix")
      .to_return(status: 200, body:, headers: { "Content-Type" => "application/json" })
  end
end
