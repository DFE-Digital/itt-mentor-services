class Placements::TravelTime
  include ServicePattern

  def initialize(origin_address:, destinations:, travel_mode: "DRIVE")
    @origin_address = origin_address
    @destinations = destinations
    @travel_mode = travel_mode
  end

  def call
    travel_time_data = Rails.cache.fetch(cache_key(origin_address:, destinations:, travel_mode:), expires_in: 1.day) do
      routes_client.travel_time(origin_address, destinations, travel_mode:)
    end

    combine_destinations_with_travel_data(travel_time_data)
  end

  private

  attr_reader :origin_address, :destinations, :travel_mode

  def routes_client
    @routes_client ||= Google::RoutesApi.new
  end

  def combine_destinations_with_travel_data(travel_time_data)
    destinations.map.with_index do |destination, index|
      api_data = travel_time_data.find { |datum| datum["destinationIndex"] == index }
      travel_duration = api_data.dig("localizedValues", "duration", "text")
      travel_distance = api_data.dig("localizedValues", "distance", "text")

      destination.update!(travel_duration:, travel_distance:)
    end

    destinations.sort_by(&:travel_duration)
  end

  def cache_key(origin_address:, destinations:, travel_mode:)
    # An array of everything that makes this request unique
    request_parameters = [origin_address, destinations.ids, travel_mode]

    # Create a SHA256 hash which uniquely identifies this request
    fingerprint = Digest::SHA256.hexdigest(request_parameters.to_json)

    "placements_travel_time_#{fingerprint}"
  end
end
