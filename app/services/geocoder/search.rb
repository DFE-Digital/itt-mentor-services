module Geocoder
  class Search
    include ServicePattern

    COUNTRY = "United Kingdom".freeze
    # The greatest distance between two points is
    # 838 miles (between Land's End, Cornwall and John o' Groats, Caithness)
    UK_LENGTH = 838

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
