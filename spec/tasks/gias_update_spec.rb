require "rails_helper"
require "rake"

describe "gias_update" do
  Rails.application.load_tasks if Rake::Task.tasks.empty?
  subject(:gias_update) { Rake::Task["gias_update"].invoke }

  it "runs Gias::SyncAllSchoolsJob" do
    expect(Gias::SyncAllSchoolsJob).to receive(:perform_now)
    gias_update
  end
end
