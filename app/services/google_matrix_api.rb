class GoogleMatrixApi
  include ServicePattern

  attr_reader :destination_place

  def initialize(origin:, destination:, travel_type:)
    @travel_type = travel_type
    @matrix = GoogleDistanceMatrix::Matrix.new
    setup_config

    origin_place = GoogleDistanceMatrix::Place.new lng: origin.longitude, lat: origin.latitude
    @destination_place = GoogleDistanceMatrix::Place.new lng: destination.longitude, lat: destination.latitude
    @matrix.origins << origin_place
    @matrix.destinations << destination_place
  end

  def call
    matrix
  end

  def duration
    matrix.shortest_route_by_duration_to(destination_place).duration_text
  end

  private

  attr_reader :matrix, :travel_type

  def setup_config
    matrix.configure do |config|
      config.mode = travel_type

      # If you have an API key, you can specify that as well.
      config.google_api_key = ENV["GOOGLE_MAPS_API_KEY"]
    end
  end
end
