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
end
