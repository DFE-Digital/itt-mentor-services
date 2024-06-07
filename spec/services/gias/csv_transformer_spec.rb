require "rails_helper"

RSpec.describe Gias::CsvTransformer do
  subject(:output_file) { described_class.call(input_file) }

  let(:input_file_path) { "spec/fixtures/gias/gias_subset.csv" }
  let(:input_file) { File.open(input_file_path, "r") }

  it_behaves_like "a service object" do
    let(:params) { { 0 => input_file } }
  end

  it "transforms the GIAS CSV" do
    # Stub Gias::CsvTransformer::CoordinateTransformer to control the latitude/longitude
    # values in this test, because proj cs2cs output can vary slightly depending on platform
    # and we need it to exactly match the values in the transformed CSV.
    # This test is primarily concerned with the overall content and strucutre of the
    # transformed CSV rather than specific latitude/longitude values.
    stub_coordinate_transformer
    expected_output = File.read("spec/fixtures/gias/gias_subset_transformed.csv")
    actual_output = output_file.read
    expect(actual_output).to eq(expected_output)
  end

  it "converts Easting/Northing to Latitude/Longitude" do
    output_csv = CSV.new(output_file, headers: true)

    expected_coordinates = [
      { easting: "533498", northing: "181201", latitude: 51.5139702631, longitude: -0.0775045667 },
      { easting: "529819", northing: "178495", latitude: 51.4905084881, longitude: -0.1314887113 },
      { easting: "284509", northing: "77456", latitude: 50.5853706802, longitude: -3.6327567586 },
      { easting: "417927", northing: "305209", latitude: 52.6443444763, longitude: -1.7364805658 },
    ]

    expected_coordinates.each do |expected|
      row = output_csv.readline
      expect(row["Easting"]).to eq(expected[:easting])
      expect(row["Northing"]).to eq(expected[:northing])
      expect(row["Latitude"].to_f).to match_coordinate(expected[:latitude])
      expect(row["Longitude"].to_f).to match_coordinate(expected[:longitude])
    end
  end

  it "filters out schools which are Closed or not in England" do
    output_csv = CSV.read(output_file, headers: true)
    urns = output_csv.values_at("URN").flatten
    expect(urns).to eq %w[100000 101173 137666 124087]
  end

  private

  def stub_coordinate_transformer
    coordinates = {
      { easting: "533498", northing: "181201" } => { latitude: 51.5139702631, longitude: -0.0775045667 },
      { easting: "529819", northing: "178495" } => { latitude: 51.4905084881, longitude: -0.1314887113 },
      { easting: "284509", northing: "77456" } => { latitude: 50.5853706802, longitude: -3.6327567586 },
      { easting: "417927", northing: "305209" } => { latitude: 52.6443444763, longitude: -1.7364805658 },
    }

    stub = instance_double("Gias::CsvTransformer::CoordinateTransformer")
    allow(Gias::CsvTransformer::CoordinateTransformer).to receive(:new).and_return(stub)

    allow(stub).to receive(:close)
    coordinates.each do |easting_northing, latitude_longitude|
      allow(stub).to receive(:transform).with(easting_northing).and_return(latitude_longitude)
    end
  end
end
