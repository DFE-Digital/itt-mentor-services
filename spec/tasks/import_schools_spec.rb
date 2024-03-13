require "rails_helper"
require "rake"

describe "import_schools" do
  describe "import" do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    subject(:import_schools) { Rake::Task["import_schools:import"].invoke }

    it "calls Claims::ImportSchools service" do
      expect(Claims::ImportSchools).to receive(:call)
      import_schools
    end
  end
end
