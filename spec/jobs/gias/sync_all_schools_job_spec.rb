require "rails_helper"

RSpec.describe Gias::SyncAllSchoolsJob, type: :job do
  it "calls Gias::CsvDownloader, then Gias::CsvTransformer, then Gias::CsvImporter" do
    downloaded_csv = instance_double(Tempfile)
    transformed_csv = instance_double(Tempfile, path: "/fake/path/to/stubbed/file.csv")

    allow(Gias::CsvDownloader).to receive(:call).and_return(downloaded_csv)
    allow(Gias::CsvTransformer).to receive(:call).with(downloaded_csv).and_return(transformed_csv)

    expect(Gias::CsvImporter).to receive(:call).with(transformed_csv.path).ordered
    expect(downloaded_csv).to receive(:unlink).ordered
    expect(transformed_csv).to receive(:unlink).ordered

    described_class.perform_now
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
