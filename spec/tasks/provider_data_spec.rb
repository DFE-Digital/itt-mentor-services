require "rails_helper"
require "rake"

describe "provider_data" do
  describe "import" do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    subject(:import_provider_data) { Rake::Task["provider_data:import"].invoke }

    it "calls PublishTeacherTraining::Provider::Importer service" do
      expect(PublishTeacherTraining::Provider::Importer).to receive(:call)
      import_provider_data
    end
  end
end
