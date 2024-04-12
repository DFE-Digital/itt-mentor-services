module GeocodingHelper
  # Latitude/Longitude coordinates are typically represented as floats,
  # accurate to 10 decimal places.
  #
  # However the PROJ library translates Eastings/Northings to Latitude/Longitude
  # with slightly _less_ accuracy than that. Output from PROJ can vary based on
  # the underlying software version and/or operating system.
  #
  # The variance is _minimal_ – we're talking a difference of +/- 2 metres.
  # That's perfectly acceptable for our use case (geolocating schools).
  #
  # We need the test suite to tolerate these minimal levels of variance, so this
  # helper method allows us to match Latitude/Longitude coordinates which are
  # 'close enough' to still meaningfully represent a location.
  def match_coordinate(coordinate)
    be_within(0.0001).of(coordinate)
  end
end
