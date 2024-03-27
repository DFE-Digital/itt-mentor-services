require "rails_helper"

describe Placements::PlacementsQuery do
  it_behaves_like "a query object", Placement, "by_status"

  describe "#filter" do
    context "when given no filters" do
      let!(:placements) { create_list(:placement, 5) }

      context "when given no scope of placements" do
        it "returns all placements" do
          expect(
            described_class.filter(filters: {}),
          ).to match_array(placements)
        end
      end

      context "when given a limited scope of placements" do
        let(:scoped_placements) { placements.first(3) }

        it "returns the limit scope of placements" do
          expect(
            described_class.filter(
              scope: scoped_placements, filters: {},
            ),
          ).to match_array(scoped_placements)
        end
      end
    end

    context "when given filters" do
      describe "#by_status" do
        let!(:draft_placements) { create_list(:placement, 5, :draft) }
        let(:published_placements) { create_list(:placement, 5) }

        before do
          published_placements
        end

        it "returns all placements with a given status" do
          expect(
            described_class.filter(filters: { status: "draft" }),
          ).to match_array(draft_placements)
        end
      end

      describe "#by_subject_id" do
        let(:filter_subject) { create(:subject) }
        let!(:placement_1) { create(:placement, subjects: [filter_subject]) }
        let(:placement_2) { create(:placement) }

        before do
          placement_2
        end

        it "returns only placements associated with that subject" do
          expect(
            described_class.filter(filters: { subject_id: filter_subject.id }),
          ).to match_array([placement_1])
        end
      end

      describe "#by_school_type" do
        let(:school_type) { "Community school" }
        let(:filtered_school) { create(:placements_school, type_of_establishment: school_type) }
        let!(:placement_1) { create(:placement, school: filtered_school) }
        let(:placement_2) { create(:placement) }

        before do
          placement_2
        end

        it "returns only placements associated with schools of a given type" do
          expect(
            described_class.filter(filters: { school_type: }),
          ).to match_array([placement_1])
        end
      end

      describe "#by_gender" do
        let(:filtered_gender) { "Boys" }
        let(:filtered_school) { create(:placements_school, gender: filtered_gender) }
        let!(:placement_1) { create(:placement, school: filtered_school) }
        let(:placement_2) { create(:placement) }

        before do
          placement_2
        end

        it "returns only placements associated with schools of a given gender" do
          expect(
            described_class.filter(filters: { gender: filtered_gender }),
          ).to match_array([placement_1])
        end
      end

      describe "by_religious_character" do
        let(:filtered_religion) { "Christian" }
        let(:filtered_school) { create(:placements_school, religious_character: filtered_religion) }
        let!(:placement_1) { create(:placement, school: filtered_school) }
        let(:placement_2) { create(:placement) }

        before do
          placement_2
        end

        it "returns only placements associated with schools of a given religious character" do
          expect(
            described_class.filter(filters: { religious_character: filtered_religion }),
          ).to match_array([placement_1])
        end
      end

      describe "#by_ofsted_rating" do
        let(:filtered_rating) { "Outstanding" }
        let(:filtered_school) { create(:placements_school, rating: filtered_rating) }
        let!(:placement_1) { create(:placement, school: filtered_school) }
        let(:placement_2) { create(:placement) }

        before do
          placement_2
        end

        it "returns only placements associated with schools of a given ofsted rating" do
          expect(
            described_class.filter(filters: { ofsted_rating: filtered_rating }),
          ).to match_array([placement_1])
        end
      end

      describe "by_name_urn_postcode" do
        let(:filter_param) { "LO" }
        let(:filtered_name_school) { create(:placements_school, name: "London College") }
        let(:filtered_urn_school) do
          create(:placements_school,
                 name: "Random School 1",
                 urn: "LO1234")
        end
        let(:filtered_postcode_school) do
          create(:placements_school,
                 name: "Random School 1",
                 postcode: "LO12 0AB")
        end
        let!(:filtered_placement_1) { create(:placement, school: filtered_name_school) }
        let!(:filtered_placement_2) { create(:placement, school: filtered_urn_school) }
        let!(:filtered_placement_3) { create(:placement, school: filtered_postcode_school) }
        let(:other_placements) { create_list(:placement, 2) }

        before do
          other_placements
        end

        it "returns only placements associated with schools with either name,
          urn or postcode similar to the given parameter" do
          expect(
            described_class.filter(filters: { name_urn_postcode: filter_param }),
          ).to match_array([filtered_placement_1, filtered_placement_2, filtered_placement_3])
        end
      end
    end
  end
end
