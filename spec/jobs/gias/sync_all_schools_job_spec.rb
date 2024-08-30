require "rails_helper"

RSpec.describe Gias::SyncAllSchoolsJob, type: :job do
  it "calls Gias::CSVDownloader, then Gias::CSVTransformer, then Gias::CSVImporter" do
    downloaded_csv = instance_double(Tempfile)
    transformed_csv = instance_double(Tempfile, path: "/fake/path/to/stubbed/file.csv")

    allow(Gias::CSVDownloader).to receive(:call).and_return(downloaded_csv)
    allow(Gias::CSVTransformer).to receive(:call).with(downloaded_csv).and_return(transformed_csv)

    expect(Gias::CSVImporter).to receive(:call).with(transformed_csv.path).ordered
    expect(downloaded_csv).to receive(:unlink).ordered
    expect(transformed_csv).to receive(:unlink).ordered

    described_class.perform_now
  end

  describe "integration test" do
    let(:gias_csv_url) do
      yesterday = Time.zone.yesterday.strftime("%Y%m%d")
      base_url = ENV.fetch("GIAS_CSV_BASE_URL")
      "#{base_url}/edubasealldata#{yesterday}.csv"
    end

    let(:gias_csv_file) { File.open("spec/fixtures/gias/gias_subset.csv") }

    before do
      stub_request(:get, gias_csv_url).to_return(status: 200, body: gias_csv_file)
    end

    it "downloads and imports school data from GIAS" do
      expect { described_class.perform_now }.to change(School, :count).from(0).to(5)

      expected_schools = [
        {
          urn: "100000",
          name: "The Aldgate School",
          latitude: 51.5139702631,
          longitude: -0.0775045667,
        },
        {
          urn: "137666",
          name: "Chudleigh Knighton Church of England Primary School",
          latitude: 50.5853706802,
          longitude: -3.6327567586,
        },
        {
          urn: "124087",
          name: "Thomas Barnes Primary School",
          latitude: 52.6443444763,
          longitude: -1.7364805658,
        },
        {
          urn: "101173",
          name: "Fairley House School",
          latitude: 51.4905084881,
          longitude: -0.1314887113,
        },
        {
          urn: "126370",
          name: "Westbury Leigh CofE Primary School",
          latitude: 51.2517381483,
          longitude: -2.2021246541,
        },
      ]

      expected_schools.each do |expected|
        school = School.find_by!(urn: expected[:urn])
        expect(school.name).to eq(expected[:name])
        expect(school.latitude).to match_coordinate(expected[:latitude])
        expect(school.longitude).to match_coordinate(expected[:longitude])
      end
    end
  end
end
