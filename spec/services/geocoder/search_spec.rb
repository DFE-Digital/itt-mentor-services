require "rails_helper"

RSpec.describe Geocoder::Search do
  context "when given a location in the UK" do
    before do
      uk_location_request
    end

    it "returns the first details for the given UK address" do
      expect(
        described_class.call("London"),
      ).to eq(london_response.first)
    end
  end

  context "when given a postcode for a region in the UK" do
    before do
      full_uk_postcode_request
    end

    it "returns the first details for the given UK postcode" do
      expect(
        described_class.call("EC3A 5DE"),
      ).to eq(full_postcode_response.first)
    end
  end

  context "when given a partial postcode for a region in the UK" do
    before do
      partial_uk_postcode_request
    end

    it "returns the first details for the given UK postcode" do
      expect(
        described_class.call("EC3A 5DE"),
      ).to eq(partial_postcode_response.first)
    end
  end

  context "when given a location not in the UK" do
    before do
      non_uk_location_request
    end

    it "returns a response for the center of the UK" do
      expect(
        described_class.call("Texas"),
      ).to eq(non_uk_location_response.first)
    end
  end

  private

  def uk_location_request
    allow(Geocoder).to receive(:search).and_return(london_response)
  end

  def full_uk_postcode_request
    allow(Geocoder).to receive(:search).and_return(full_postcode_response)
  end

  def partial_uk_postcode_request
    allow(Geocoder).to receive(:search).and_return(partial_postcode_response)
  end

  def non_uk_location_request
    allow(Geocoder).to receive(:search).and_return(non_uk_location_response)
  end

  # responses are examples received from Geocoder

  def london_response
    [
      {
        "address_components" =>
        [
          { "long_name" => "London", "short_name" => "London", "types" => %w[locality political] },
          { "long_name" => "London", "short_name" => "London", "types" => %w[postal_town] },
          { "long_name" => "Greater London", "short_name" => "Greater London", "types" => %w[administrative_area_level_2 political] },
          { "long_name" => "England", "short_name" => "England", "types" => %w[administrative_area_level_1 political] },
          { "long_name" => "United Kingdom", "short_name" => "GB", "types" => %w[country political] },
        ],
        "formatted_address" => "London, UK",
        "geometry" =>
        { "bounds" => { "northeast" => { "lat" => 51.6723432, "lng" => 0.148271 }, "southwest" => { "lat" => 51.38494009999999, "lng" => -0.3514683 } },
          "location" => { "lat" => 51.5072178, "lng" => -0.1275862 },
          "location_type" => "APPROXIMATE",
          "viewport" => { "northeast" => { "lat" => 51.6723432, "lng" => 0.148271 }, "southwest" => { "lat" => 51.38494009999999, "lng" => -0.3514683 } } },
        "place_id" => "ChIJdd4hrwug2EcRmSrV3Vo6llI",
        "types" => %w[locality political],
      },
    ]
  end

  def full_postcode_response
    [
      {
        "address_components" =>
          [
            { "long_name" => "EC3A 5DE", "short_name" => "EC3A 5DE", "types" => %w[postal_code] },
            { "long_name" => "London", "short_name" => "London", "types" => %w[postal_town] },
            { "long_name" => "Greater London", "short_name" => "Greater London", "types" => %w[administrative_area_level_2 political] },
            { "long_name" => "England", "short_name" => "England", "types" => %w[administrative_area_level_1 political] },
            { "long_name" => "United Kingdom", "short_name" => "GB", "types" => %w[country political] },
          ],
        "formatted_address" => "London EC3A 5DE, UK",
        "geometry" =>
          { "bounds" => { "northeast" => { "lat" => 51.5141777, "lng" => -0.07633039999999999 }, "southwest" => { "lat" => 51.5132092, "lng" => -0.0782785 } },
            "location" => { "lat" => 51.5136637, "lng" => -0.0774598 },
            "location_type" => "APPROXIMATE",
            "viewport" => { "northeast" => { "lat" => 51.5150424302915, "lng" => -0.07595546970849797 }, "southwest" => { "lat" => 51.5123444697085, "lng" => -0.07865343029150203 } } },
        "place_id" => "ChIJn9fBvkwDdkgRwmpFTepw9nY",
        "types" => %w[postal_code],
      },
    ]
  end

  def partial_postcode_response
    [
      { "address_components" =>
        [
          { "long_name" => "EC3A", "short_name" => "EC3A", "types" => %w[postal_code postal_code_prefix] },
          { "long_name" => "London", "short_name" => "London", "types" => %w[postal_town] },
          { "long_name" => "Greater London", "short_name" => "Greater London", "types" => %w[administrative_area_level_2 political] },
          { "long_name" => "England", "short_name" => "England", "types" => %w[administrative_area_level_1 political] },
          { "long_name" => "United Kingdom", "short_name" => "GB", "types" => %w[country political] },
        ],
        "formatted_address" => "London EC3A, UK",
        "geometry" =>
        { "bounds" => { "northeast" => { "lat" => 51.5160754, "lng" => -0.0742659 }, "southwest" => { "lat" => 51.5126515, "lng" => -0.0828445 } },
          "location" => { "lat" => 51.5143245, "lng" => -0.0785068 },
          "location_type" => "APPROXIMATE",
          "viewport" => { "northeast" => { "lat" => 51.5160754, "lng" => -0.0742659 }, "southwest" => { "lat" => 51.5126515, "lng" => -0.0828445 } } },
        "place_id" => "ChIJLax5sUwDdkgRcxxFTWJf0kY",
        "types" => %w[postal_code postal_code_prefix] },
    ]
  end

  def non_uk_location_response
    [
      { "address_components" => [
          { "long_name" => "United Kingdom", "short_name" => "GB", "types" => %w[country political] },
        ],
        "formatted_address" => "United Kingdom",
        "geometry" =>
        { "bounds" => { "northeast" => { "lat" => 60.91569999999999, "lng" => 33.9165549 }, "southwest" => { "lat" => 34.5614, "lng" => -8.8988999 } },
          "location" => { "lat" => 55.378051, "lng" => -3.435973 },
          "location_type" => "APPROXIMATE",
          "viewport" => { "northeast" => { "lat" => 61.5471111, "lng" => 9.5844157 }, "southwest" => { "lat" => 47.5554486, "lng" => -18.5319589 } } },
        "partial_match" => true,
        "place_id" => "ChIJqZHHQhE7WgIReiWIMkOg-MQ",
        "types" => %w[country political] },
      { "address_components" =>
        [
          { "long_name" => "Texas", "short_name" => "TX", "types" => %w[administrative_area_level_1 political] },
          { "long_name" => "United States", "short_name" => "US", "types" => %w[country political] },
        ],
        "formatted_address" => "Texas, USA",
        "geometry" =>
        { "bounds" => { "northeast" => { "lat" => 36.5007041, "lng" => -93.5080389 }, "southwest" => { "lat" => 25.8371165, "lng" => -106.6456461 } },
          "location" => { "lat" => 31.9685988, "lng" => -99.9018131 },
          "location_type" => "APPROXIMATE",
          "viewport" => { "northeast" => { "lat" => 36.50112610000001, "lng" => -93.5080389 }, "southwest" => { "lat" => 25.8371165, "lng" => -106.6456461 } } },
        "partial_match" => true,
        "place_id" => "ChIJSTKCCzZwQIYRPN4IGI8c6xY",
        "types" => %w[administrative_area_level_1 political] },
    ]
  end
end
