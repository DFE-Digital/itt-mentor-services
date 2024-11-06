require "rails_helper"

RSpec.describe "Provider user filters placements by search by location", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_all_placements
    and_i_see_the_search_by_location_filter

    when_i_search_for_schools_near_guildford
    and_i_click_on_apply_filters
    then_i_see_the_guildford_school_placement
    and_i_do_not_see_the_bath_school_placement
    and_i_see_the_guildford_search_by_location_filter

    when_i_search_for_schools_in_a_made_up_location
    and_i_click_on_apply_filters
    then_i_see_no_placements
    and_i_see_my_made_up_location_search_by_location_filter
    and_i_do_not_see_my_guildford_search_by_location_filter

    when_i_click_on_the_made_up_location_search_by_location_filter_tag
    then_i_see_all_placements
    and_i_do_not_see_any_selected_search_by_location_filters
  end

  private

  def given_that_placements_exist
    @provider = build(:placements_provider, name: "Aes Sedai Trust")

    @guildford_school = build(:placements_school, phase: "Primary", name: "Springfield Elementary", latitude: 51.23622,
                                                  longitude: -0.570409)
    @primary_maths_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    _guildford_school_placement = create(:placement, school: @guildford_school, subject: @primary_maths_subject)

    @bath_school = build(:placements_school, phase: "Secondary", name: "Hogwarts", latitude: 51.3781018,
                                             longitude: -2.3596827)
    @secondary_english_subject = build(:subject, name: "English", subject_area: "secondary")
    _bath_school_placement = create(:placement, school: @bath_school, subject: @secondary_english_subject)

    stub_geocoder_results
    stub_routes_request
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
    expect(page).to have_h2("Primary with mathematics – Springfield Elementary")
    expect(page).to have_h2("English – Hogwarts")
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

  def then_i_see_the_guildford_school_placement
    expect(page).to have_h2("Primary with mathematics – Springfield Elementary")
    expect(page).to have_result_detail_row("Distance", "0.0 mi")
    expect(page).to have_result_detail_row("Public transport", "42 minutes")
    expect(page).to have_result_detail_row("Driving", "42 minutes")
    expect(page).to have_result_detail_row("Walking", "42 minutes")
  end

  def and_i_do_not_see_the_bath_school_placement
    expect(page).not_to have_h2("English – Hogwarts")
  end

  def and_i_see_the_guildford_search_by_location_filter
    expect(page).to have_filter_tag("Guildford")
    expect(page).to have_field("Enter a town, city or postcode", type: :search, with: "Guildford")
  end

  def when_i_search_for_schools_in_a_made_up_location
    fill_in "Enter a town, city or postcode", with: "Mordor"
  end

  def then_i_see_no_placements
    expect(page).to have_h2("No placements")
    expect(page).to have_element(:p, text: "There are no placements that match your selection. Try searching again, or removing one or more filters.")
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
    expect(page).not_to have_result_detail_row("Public transport", "42 minutes")
    expect(page).not_to have_result_detail_row("Driving", "42 minutes")
    expect(page).not_to have_result_detail_row("Walking", "42 minutes")
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
