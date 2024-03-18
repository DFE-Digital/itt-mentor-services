module GeocoderStub
  def self.stub_with(school)
    Geocoder.configure(lookup: :test)

    results = [
      {
        "latitude" => Faker::Address.latitude,
        "longitude" => Faker::Address.longitude,
      },
    ]

    queries = [school.address, school.postcode]
    queries.each { |q| Geocoder::Lookup::Test.add_stub(q, results) }
  end
end
