require "rails_helper"

RSpec.describe GiasCsvImporter do
  subject { described_class.call("spec/fixtures/test_gias_import.csv") }

  it "inserts the correct schools" do
    expect { subject }.to change(School, :count).from(0).to(4)
  end

  it "updates the correct schools" do
    school = create(:school, urn: "123")
    expect { subject }.to change { school.reload.name }.to "FringeSchool"
  end

  it "logs messages to STDOUT" do
    expect(Rails.logger).to receive(:info).with("Invalid rows - [\"Row 8 is invalid\"]")
    expect(Rails.logger).to receive(:info).with("Associating the first 1000 schools to regions")
    expect(Rails.logger).to receive(:info).with("Done!")

    subject
  end

  it "associates schools to regions" do
    subject

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
