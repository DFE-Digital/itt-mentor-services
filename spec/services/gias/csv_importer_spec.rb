require "rails_helper"

RSpec.describe Gias::CSVImporter do
  subject(:gias_importer) { described_class.call(csv_path) }

  let(:csv_path) { "spec/fixtures/gias/import_with_trusts_and_regions.csv" }

  it_behaves_like "a service object" do
    let(:params) { { csv_path: } }
  end

  it "creates new schools" do
    expect { gias_importer }.to change(School, :count).from(0).to(5)
  end

  it "updates existing schools" do
    school = create(:school, urn: "123", name: "The wrong name")
    expect { gias_importer }.to change { school.reload.name }.to "FringeSchool"
  end

  it "logs messages to STDOUT" do
    expect(Rails.logger).to receive(:info).with("GIAS Data Imported!")

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

  describe "associating schools with trusts" do
    context "when the trust does not exist" do
      it "creates the trust" do
        expect { gias_importer }.to change(Trust, :count).from(0).to(1)
      end

      it "associates schools to the trust" do
        gias_importer
        trust = Trust.find_by(uid: "12345")
        school = School.find_by(urn: "140")

        expect(school.trust).to eq(trust)
      end
    end

    context "when the trust already exists" do
      before do
        create(:trust, uid: "12345")
      end

      it "does not create a new trust" do
        expect { gias_importer }.not_to change(Trust, :count)
      end

      it "associates schools to the trust" do
        gias_importer
        trust = Trust.find_by(uid: "12345")
        school = School.find_by(urn: "140")

        expect(school.trust).to eq(trust)
      end
    end

    context "when the school is not associated with a trust" do
      it "does not associate the school to a trust" do
        gias_importer
        school = School.find_by(urn: "132")

        expect(school.trust).to be_nil
      end
    end
  end

  describe "geocoding schools" do
    subject(:school) { School.find_by!(urn:) }

    before { gias_importer }

    context "when the CSV has a Latitude/Longitude for the school" do
      let(:urn) { "130" }

      it "geocodes the school" do
        expect(school).to be_geocoded
        expect(school.latitude).to eq(51.5139702631)
        expect(school.longitude).to eq(-0.0775045667)
      end
    end

    context "when the CSV doesn't provide a Latitude/Longitude for the school" do
      let(:urn) { "131" }

      it "imports the school but does not geocode it" do
        expect(school).not_to be_geocoded
        expect(school.latitude).to be_nil
        expect(school.longitude).to be_nil
      end
    end
  end
end
