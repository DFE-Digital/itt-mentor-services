require "rails_helper"

RSpec.describe Gias::CSVImporter do
  subject(:gias_importer) { described_class.call(csv_path) }

  let(:csv_path) { "spec/fixtures/gias/import_with_trusts_and_regions.csv" }

  it_behaves_like "a service object" do
    let(:params) { { csv_path: } }
  end

  it "creates new schools" do
    expect { gias_importer }.to change(School, :count).from(0).to(6)
  end

  it "updates existing schools" do
    school = create(:school, urn: "123", name: "The wrong name")
    expect { gias_importer }.to change { school.reload.name }.to "FringeSchool"
  end

  it "logs messages to STDOUT" do
    expect(Rails.logger).to receive(:info).with("GIAS Data Imported!")
    expect(Rails.logger).to receive(:info).with("Deleted schools which have been closed from the database.")

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

  context "when URN is not present" do
    let(:csv_path) { "spec/fixtures/gias/import_with_trusts_and_regions_without_urn.csv" }

    it "does not create a school" do
      expect { gias_importer }.not_to change(School, :count)
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

  describe "associating schools with sen provisions" do
    context "when SEN provisions do not exist" do
      it "creates a SEN provision per SEN attribute in the GIAS data" do
        expect { gias_importer }.to change(SENProvision, :count).from(0).to(13)
          .and change(SchoolSENProvision, :count).from(0).to(13)
        school = School.find_by(urn: 142)
        expect(school.sen_provisions.pluck(:name)).to contain_exactly(
          "ASD - Autistic Spectrum Disorder",
          "HI - Hearing Impairment",
          "MLD - Moderate Learning Difficulty",
          "MSI - Multi-Sensory Impairment",
          "Not Applicable",
          "OTH - Other Difficulty/Disability",
          "PD - Physical Disability",
          "PMLD - Profound and Multiple Learning Difficulty",
          "SEMH - Social, Emotional and Mental Health",
          "SLCN - Speech, language and Communication",
          "SLD - Severe Learning Difficulty",
          "SpLD - Specific Learning Difficulty",
          "VI - Visual Impairment",
        )
      end
    end

    context "when SEN provisions already exist" do
      before do
        create(:sen_provision, name: "ASD - Autistic Spectrum Disorder")
        create(:sen_provision, name: "HI - Hearing Impairment")
        create(:sen_provision, name: "MLD - Moderate Learning Difficulty")
        create(:sen_provision, name: "MSI - Multi-Sensory Impairment")
        create(:sen_provision, name: "Not Applicable")
        create(:sen_provision, name: "OTH - Other Difficulty/Disability")
        create(:sen_provision, name: "PD - Physical Disability")
        create(:sen_provision, name: "PMLD - Profound and Multiple Learning Difficulty")
        create(:sen_provision, name: "SEMH - Social, Emotional and Mental Health")
        create(:sen_provision, name: "SLCN - Speech, language and Communication")
        create(:sen_provision, name: "SLD - Severe Learning Difficulty")
        create(:sen_provision, name: "SpLD - Specific Learning Difficulty")
        create(:sen_provision, name: "VI - Visual Impairment")
      end

      it "does not create any additional SEN provisions" do
        expect { gias_importer }.not_to change(SENProvision, :count)
      end

      context "when a school is already associated with SEN provisions" do
        let(:school) { build(:school, urn: 142, name: "SenSchool") }

        before do
          school.sen_provisions = SENProvision.all
          school.save!
        end

        it "does not create any additional joins between schools and SEN provisions" do
          expect { gias_importer }.not_to change(SchoolSENProvision, :count)
        end
      end
    end
  end

  describe "Removing schools that have been closed" do
    context "when the school has not been onboarded" do
      let(:school) { create(:school, urn: "999") }

      before { school }

      it "is removed from the database" do
        expect { gias_importer }.to change { School.exists?(id: school.id) }.from(true).to(false)
      end
    end

    context "when the school has partnerships" do
      let(:school) { build(:school, urn: "999") }

      before do
        create(:placements_partnership, school:)
      end

      it "is not removed from the database" do
        expect { gias_importer }.not_to change { School.exists?(id: school.id) }.from(true)
      end
    end

    context "when the school has been onboarded to the placements service" do
      let(:school) { create(:school, urn: "999", placements_service: true) }

      it "is not removed from the database" do
        expect { gias_importer }.not_to change { School.exists?(id: school.id) }.from(true)
      end
    end

    context "when the school has been onboarded to the claims service" do
      let(:school) { create(:school, urn: "999", claims_service: true) }

      it "is not removed from the database" do
        expect { gias_importer }.not_to change { School.exists?(id: school.id) }.from(true)
      end
    end

    context "when the school has been onboarded to both services" do
      let(:school) { create(:school, urn: "999", placements_service: true, claims_service: true) }

      it "is not removed from the database" do
        expect { gias_importer }.not_to change { School.exists?(id: school.id) }.from(true)
      end
    end

    context "when the school has not been closed" do
      let(:school) { create(:school, urn: "142") }

      it "is not removed from the database" do
        expect { gias_importer }.not_to change { School.exists?(id: school.id) }.from(true)
      end
    end
  end
end
