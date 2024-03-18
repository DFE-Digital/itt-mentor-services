require "rails_helper"

RSpec.describe Gias::CsvImporter do
  subject(:gias_importer) { described_class.call(file_path) }

  it_behaves_like "a service object"

  context "with an invalid row in the csv" do
    # CSV contains 4 valid schools and 3 invalid schools
    let(:file_path) { "spec/fixtures/gias/import_with_invalid_schools.csv" }

    it "inserts the correct schools" do
      expect { gias_importer }.to change(School, :count).from(0).to(5)
    end

    it "updates the correct schools" do
      school = create(:school, urn: "123")
      expect { gias_importer }.to change { school.reload.name }.to "FringeSchool"
    end

    it "logs messages to STDOUT" do
      expect(Rails.logger).to receive(:info).with("Invalid rows - [\"Row 8 is invalid\"]")
      expect(Rails.logger).to receive(:info).with("GIAS Data Imported!")

      gias_importer
    end

    describe "regions" do
      context "when associating regions" do
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
    end

    describe "trusts" do
      context "when associating trusts" do
        context "and the trust does not exist" do
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

        context "and the trust already exists" do
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

        context "and the school is not associated with a trust" do
          it "does not associate the school to a trust" do
            gias_importer
            school = School.find_by(urn: "132")

            expect(school.trust).to be_nil
          end
        end
      end
    end
  end

  context "with all valid rows in the csv" do
    # CSV contains 4 valid schools
    let(:file_path) { "spec/fixtures/gias/import_with_all_valid_schools.csv" }

    it "inserts the correct schools" do
      expect { gias_importer }.to change(School, :count).from(0).to(4)
    end

    it "logs messages to STDOUT" do
      expect(Rails.logger).not_to receive(:info).with("Invalid rows - [\"Row 8 is invalid\"]")
      expect(Rails.logger).to receive(:info).with("GIAS Data Imported!")

      gias_importer
    end
  end
end
