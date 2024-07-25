module Google
  class RoutesApi
    include HTTParty

    UNITS = "IMPERIAL".freeze

    base_uri "https://routes.googleapis.com"
    headers "Accept" => "application/json",
            "Content-Type" => "application/json;odata.metadata=minimal",
            "X-Goog-Api-Key" => ENV.fetch("GOOGLE_MAPS_API_KEY", "").to_s,
            "X-Goog-FieldMask" => "localizedValues,destinationIndex"

    def travel_time(origin_address, destinations, travel_mode: "DRIVE")
      self.class.post("/distanceMatrix/v2:computeRouteMatrix", body: options(origin_address, destinations, travel_mode))
    end

    private

    def options(origin_address, destinations, travel_mode)
      @options ||= {
        origins: [transform_origin(origin_address)],
        destinations: destinations.map { |destination| transform_destination(destination) },
        travelMode: travel_mode,
        units: UNITS,
      }.to_json
    end

    def transform_destination(destination)
      {
        waypoint: {
          location: {
            latLng: {
              latitude: destination.latitude,
              longitude: destination.longitude,
            },
          },
        },
      }
    end

    def transform_origin(address)
      {
        waypoint: {
          address:,
        },
      }
    end
  end
end
