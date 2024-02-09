require "rails_helper"

RSpec.describe GiasCsvImporter do
  subject(:gias_importer) { described_class.call("spec/fixtures/test_gias_import.csv") }

  it "inserts the correct schools" do
    expect { gias_importer }.to change(School, :count).from(0).to(4)
  end

  it "updates the correct schools" do
    school = create(:school, urn: "123")
    expect { gias_importer }.to change { school.reload.name }.to "FringeSchool"
  end

  it "logs messages to STDOUT" do
    expect(Rails.logger).to receive(:info).with("Invalid rows - [\"Row 8 is invalid\"]")
    expect(Rails.logger).to receive(:info).with("Done!")

    gias_importer
  end

  it "associates schools to regions" do
    gias_importer

    inner_london_school = School.find_by(urn: "130")
    outer_london_school = School.find_by(urn: "131")
    fringe_school = School.find_by(urn: "123")
    rest_of_england_school = School.find_by(urn: "132")

    expect(inner_london_school.region.name).to eq("Inner London")
    expect(outer_london_school.region.name).to eq("Outer London")
    expect(fringe_school.region.name).to eq("Fringe")
    expect(rest_of_england_school.region.name).to eq("Rest of England")
  end
end
