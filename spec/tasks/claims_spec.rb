require "rails_helper"
require "rake"

describe "claims" do
  describe "import_schools" do
    Rails.application.load_tasks if Rake::Task.tasks.empty?

    subject(:import_schools) { Rake::Task["claims:import_schools"].invoke }

    let(:csv_string) { "provider_name,placement_school_urn,placement_school_name,First name,Last name,Email\nBest Practice Network,40435,Yeo Moor Primary School,Bob,Yargen,bob1@gmail.com\nBest Practice Network,40431,Yargen Primary School,Bob,Yargen,bob2@gmail.com\nBest Practice Network,40432,Bob Primary School,Bob,Yargen,bob3@gmail.com\nBest Practice Network,40439,another Primary School,#N/A,#N/A,#N/A\nBest Practice Network,40440,Not matching School,#N/A,#N/A,#N/A" }
    let(:encrypted_mock) { instance_double(encrypted, read: csv_string) }

    it "calls Claims::ImportSchools service" do
      expect(Claims::ImportSchools).to receive(:call)
      allow(Rails.application).to receive(:encrypted).and_return(encrypted_mock)
      import_schools
    end
  end
end
