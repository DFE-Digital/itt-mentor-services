require "rails_helper"

RSpec.describe Placements::TravelTime do
  let(:origin_address) { "SW1A 1AA" }
  let(:placements_schools) { create_list(:placements_school, 3, longitude: 1.2, latitude: 0.2) }
  let(:destinations) { Placements::School.all }

  before { placements_schools }

  it_behaves_like "a service object" do
    let(:params) do
      {
        origin_address:,
        destinations:,
      }
    end
  end

  describe "#call" do
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
      expect(results.pluck(:drive_travel_distance)).to eq ["17.5 mi", "20 mi", "22 mi"]
      expect(results.pluck(:transit_travel_duration)).to eq ["36 mins", "42 mins", "46 mins"]
      expect(results.pluck(:transit_travel_distance)).to eq ["17.5 mi", "20 mi", "22 mi"]
    end

    it "returns the school collection, sorted by travel duration" do
      results = service
      expect(results).to eq [placements_schools[1], placements_schools[0], placements_schools[2]]
    end

    it "caches the travel time data" do
      fingerprint = Digest::SHA256.hexdigest(["SW1A 1AA", destinations.pluck(:latitude, :longitude), "DRIVE"].to_json)
      service

      expect(Rails.cache.exist?("placements_travel_time_#{fingerprint}")).to be true
    end
  end
end
