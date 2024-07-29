class Placements::TravelTime
  include ServicePattern

  def initialize(origin_address:, destinations:)
    @origin_address = origin_address
    @destinations = destinations
  end

  def call
    combine_destinations_with_travel_data
  end

  private

  attr_reader :origin_address, :destinations

  DRIVE_TRAVEL_MODE = "DRIVE".freeze
  TRANSIT_TRAVEL_MODE = "TRANSIT".freeze

  def routes_client
    @routes_client ||= Google::RoutesApi.new
  end

  def combine_destinations_with_travel_data
    drive_travel_data = travel_data(travel_mode: DRIVE_TRAVEL_MODE)
    transit_travel_data = travel_data(travel_mode: TRANSIT_TRAVEL_MODE)

    destinations.map.with_index do |destination, index|
      drive_travel_datum = drive_travel_data.find { |datum| datum["destinationIndex"] == index }
      transit_travel_datum = transit_travel_data.find { |datum| datum["destinationIndex"] == index }

      destination.assign_attributes(
        drive_travel_duration: drive_travel_datum.dig("localizedValues", "duration", "text"),
        drive_travel_distance: drive_travel_datum.dig("localizedValues", "distance", "text"),
        transit_travel_duration: transit_travel_datum.dig("localizedValues", "duration", "text"),
        transit_travel_distance: transit_travel_datum.dig("localizedValues", "distance", "text"),
      )
    end

    destinations.sort_by(&:drive_travel_duration)
  end

  def travel_data(travel_mode:)
    Rails.cache.fetch(cache_key(travel_mode:), expires_in: 1.day) do
      routes_client.travel_time(origin_address, destinations, travel_mode:)
    end
  end

  def cache_key(travel_mode:)
    # An array of everything that makes this request unique
    request_parameters = [origin_address, destinations.pluck(:latitude, :longitude), travel_mode]

    # Create a SHA256 hash which uniquely identifies this request
    fingerprint = Digest::SHA256.hexdigest(request_parameters.to_json)

    "placements_travel_time_#{fingerprint}"
  end
end
