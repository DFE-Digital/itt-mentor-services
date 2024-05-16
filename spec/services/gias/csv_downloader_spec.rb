require "rails_helper"

RSpec.describe Gias::CsvDownloader do
  subject(:gias_csv_downloader) { described_class.call }

  let(:file) { Tempfile.new }

  after { file.unlink }

  it_behaves_like "a service object"

  it "downloads the GIAS CSV for yesterday's date" do
    yesterday = Time.zone.yesterday.strftime("%Y%m%d")
    gias_filename = "edubasealldata#{yesterday}.csv"

    allow(Down).to receive(:download).with(
      "#{ENV["GIAS_CSV_BASE_URL"]}/#{gias_filename}",
    ).and_return(file)

    expect(gias_csv_downloader).to eq(file)
  end

  it "sets the file encoding to ISO-8859-1" do
    allow(Down).to receive(:download).and_return(file)
    downloaded = gias_csv_downloader
    expect(downloaded.external_encoding).to be(Encoding::ISO_8859_1)
    expect(downloaded.internal_encoding).to be(Encoding::UTF_8)
  end
end
