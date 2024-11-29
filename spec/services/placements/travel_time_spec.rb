require "rails_helper"

RSpec.describe Placements::TravelTime do
  let(:origin_address) { "SW1A 1AA" }
  let(:school_a) { create(:placements_school, name: "Abbey Academy", longitude: 1.2, latitude: 0.2) }
  let(:school_b) { create(:placements_school, name: "Buxton Boarding School", longitude: 1.2, latitude: 0.2) }
  let(:school_c) { create(:placements_school, name: "Canterbury College", longitude: 1.2, latitude: 0.2) }
  let(:destinations) { Placements::School.order_by_name }

  before do
    school_a
    school_b
    school_c
  end

  it_behaves_like "a service object" do
    let(:params) do
      {
        origin_address:,
        destinations:,
      }
    end
  end

  describe "#call" do
    include_context "with cache"

    let(:service) { described_class.call(origin_address:, destinations:) }
    let(:google_routes_client) { instance_double(Google::RoutesApi) }
    let(:body) do
      [
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
            "distance" => { "text" => "17.5 mi" },
            "duration" => { "text" => "36 mins" },
            "staticDuration" => { "text" => "42 mins" },
          },
        },
        {
          "destinationIndex" => 2,
          "localizedValues" => {
            "distance" => { "text" => "22 mi" },
            "duration" => { "text" => "46 mins" },
            "staticDuration" => { "text" => "46 mins" },
          },
        },
      ]
    end

    before do
      allow(Google::RoutesApi).to receive(:new).and_return(google_routes_client)
      allow(google_routes_client).to receive(:travel_time).and_return(body)
    end

    it "returns the school collection, with the travel data appended" do
      results = service
      expect(results.pluck(:drive_travel_duration)).to eq ["36 mins", "42 mins", "46 mins"]
      expect(results.pluck(:transit_travel_duration)).to eq ["36 mins", "42 mins", "46 mins"]
      expect(results.pluck(:walk_travel_duration)).to eq ["36 mins", "42 mins", "46 mins"]
    end

    it "returns the school collection, sorted by travel duration" do
      results = service
      expect(results).to eq [school_b, school_a, school_c]
    end

    it "caches the travel time data" do
      fingerprint = Digest::SHA256.hexdigest(["SW1A 1AA", destinations.pluck(:latitude, :longitude), "DRIVE"].to_json)

      expect(google_routes_client).to receive(:travel_time).with(origin_address, destinations, travel_mode: "DRIVE").once
      expect(service).to eq(described_class.call(origin_address:, destinations:))
      expect(Rails.cache.exist?("placements_travel_time_#{fingerprint}")).to be true
    end
  end
end
