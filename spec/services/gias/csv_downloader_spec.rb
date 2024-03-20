require "rails_helper"

RSpec.describe Gias::CsvDownloader do
  subject(:gias_csv_downloader) { described_class.call }

  it_behaves_like "a service object"

  it "downloads the GIAS CSV" do
    today = Time.zone.today.strftime("%Y%m%d")
    gias_filename = "edubasealldata#{today}.csv"
    tempfile = Tempfile.new("foo")

    allow(Down).to receive(:download).with(
      "#{ENV["GIAS_CSV_BASE_URL"]}/#{gias_filename}",
    ).and_return(tempfile)

    expect(gias_csv_downloader).to eq(tempfile)
  end
end
