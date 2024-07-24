module Google
  class RoutesApi
    include HTTParty

    UNITS = "IMPERIAL".freeze

    base_uri "https://routes.googleapis.com"
    headers "Accept" => "application/json",
            "Content-Type" => "application/json;odata.metadata=minimal",
            "X-Goog-Api-Key" => ENV.fetch("GOOGLE_MAPS_API_KEY", "").to_s,
            "X-Goog-FieldMask" => "*"

    def initialize(origins:, destinations:, travel_mode: "DRIVE")
      @origins = origins
      @destinations = destinations
      @travel_mode = travel_mode
    end

    def call
      self.class.post("/distanceMatrix/v2:computeRouteMatrix", body: options)
    end

    private

    attr_reader :origins, :destinations, :travel_mode

    def options
      @options ||= {
        origins: origins.map { |origin| transform(origin) },
        destinations: destinations.map { |destination| transform(destination) },
        travelMode: travel_mode,
        units: UNITS,
      }.to_json
    end

    def transform(location)
      {
        waypoint: {
          location: {
            latLng: {
              latitude: location.latitude,
              longitude: location.longitude,
            },
          },
        },
      }
    end
  end
end
