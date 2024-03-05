require "rails_helper"
require "rake"

describe "gias_update" do
  Rails.application.load_tasks if Rake::Task.tasks.empty?
  subject(:gias_update) { Rake::Task["gias_update"].invoke }

  it "runs Gias::SyncAllSchoolsJob" do
    allow(Gias::SyncAllSchoolsJob).to receive(:perform_now)
                                   .and_raise("Gias::SyncAllSchoolsJob running")

    expect { gias_update }.to raise_error "Gias::SyncAllSchoolsJob running"
  end
end
