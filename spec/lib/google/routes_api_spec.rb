require "rails_helper"

RSpec.describe Google::RoutesApi do
  describe "#travel_time" do
    let(:origin_address) { "20 Great Smith St, London SW1P 3BT" }
    let(:destinations) { [destination] }
    let(:destination) { instance_double(School, latitude: 37.7749, longitude: -122.4194) }

    before do
      stub_google_routes_post_request
    end

    context "when travel_mode is provided" do
      subject(:travel_time) { described_class.new.travel_time(origin_address, destinations, travel_mode:) }

      let(:travel_mode) { "DRIVE" }

      it "performs a HTTP post call to the Google Routes API" do
        travel_time

        expect(a_request(:post, "https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix")).to have_been_made
      end
    end

    context "when travel_mode is not provided" do
      subject(:travel_time) { described_class.new.travel_time(origin_address, destinations) }

      it "performs a HTTP post call to the Google Routes API" do
        travel_time

        expect(a_request(:post, "https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix")).to have_been_made
      end
    end
  end

  private

  def stub_google_routes_post_request
    stub_request(:post, "https://routes.googleapis.com/distanceMatrix/v2:computeRouteMatrix")
      .with(
        body: "{\"origins\":[{\"waypoint\":{\"address\":\"20 Great Smith St, London SW1P 3BT\"}}],\"destinations\":[{\"waypoint\":{\"location\":{\"latLng\":{\"latitude\":37.7749,\"longitude\":-122.4194}}}}],\"travelMode\":\"DRIVE\",\"units\":\"IMPERIAL\"}",
        headers: {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Content-Type" => "application/json;odata.metadata=minimal",
          "User-Agent" => "Ruby",
          "X-Goog-Api-Key" => "",
          "X-Goog-Fieldmask" => "localizedValues,destinationIndex",
        },
      )
      .to_return(status: 200, body: "", headers: {})
  end
end
