require "rails_helper"

RSpec.describe Gias::SyncAllSchoolsJob, type: :job do
  describe "#perform" do
    it "calls Gias::CsvDownloader and Gias::CsvImporter service" do
      # Testing Gias::CsvDownloader
      today = Time.zone.today.strftime("%Y%m%d")
      gias_filename = "edubasealldata#{today}.csv"
      tempfile = Tempfile.new("foo")

      allow(Down).to receive(:download).with(
        "#{ENV["GIAS_CSV_BASE_URL"]}/#{gias_filename}",
      ).and_return(tempfile)

      # Testing Gias::CsvImporter
      expect(Gias::CsvImporter).to receive(:call).with(tempfile.path)
      described_class.perform_now
    end
  end

  describe "integration test" do
    let(:gias_csv_url) do
      today = Time.zone.today.strftime("%Y%m%d")
      base_url = ENV.fetch("GIAS_CSV_BASE_URL")
      "#{base_url}/edubasealldata#{today}.csv"
    end

    let(:gias_csv_file) { File.open("spec/fixtures/gias/gias_subset.csv") }

    before do
      stub_request(:get, gias_csv_url).to_return(status: 200, body: gias_csv_file)
    end

    it "downloads and imports school data from GIAS" do
      expect { described_class.perform_now }.to change(School, :count).from(0).to(3)

      expect(School.pluck(:urn, :name)).to eq [
        ["100000", "The Aldgate School"],
        ["137666", "Chudleigh Knighton Church of England Primary School"],
        ["124087", "Thomas Barnes Primary School"],
      ]
    end
  end
end
