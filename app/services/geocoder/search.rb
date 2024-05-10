module Geocoder
  class Search
    include ServicePattern

    COUNTRY = "United Kingdom".freeze

    def initialize(search_params)
      @search_params = search_params
    end

    def call
      Geocoder.search(
        "#{@search_params}, #{COUNTRY}",
      ).first
    end
  end
end
