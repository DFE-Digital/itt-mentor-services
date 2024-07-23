module Google
  class RoutingApi
    include ServicePattern
    include HTTParty
    base_uri 'https://routes.googleapis.com'

    attr_reader :origins, :destinations

    def initialize(origins:, destinations:)
      @origins = origins
      @destinations
    end

    def call
      self.class.post("/directions/v2:computeRoutes", options)
    end

    private

    def options
      @options ||= { 
        query: {
          origins:,
          destinations:,
        } 
      }
    end
  end
end