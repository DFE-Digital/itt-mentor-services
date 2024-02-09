require "rails_helper"
require "rake"

describe "gias_update" do
  Rails.application.load_tasks if Rake::Task.tasks.empty?
  subject { Rake::Task["gias_update"].invoke }

  it "calls GiasCsvImporter service" do
    today = Time.zone.today.strftime("%Y%m%d")
    gias_filename = "edubasealldata#{today}.csv"
    tempfile = Tempfile.new("foo")

    allow(Down).to receive(:download).with(
      "#{ENV["GIAS_CSV_BASE_URL"]}/#{gias_filename}",
    ).and_return(tempfile)

    expect(GiasCsvImporter).to receive(:call).with(tempfile.path)
    subject
  end
end
