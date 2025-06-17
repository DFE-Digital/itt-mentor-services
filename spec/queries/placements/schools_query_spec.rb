require "rails_helper"

describe Placements::SchoolsQuery do
  subject(:query) { described_class.new(academic_year:, params:) }

  let(:params) { {} }
  let(:provider) { create(:placements_provider) }
  let(:query_school) do
    create(
      :placements_school,
      name: "London Primary School",
      phase: "All-through",
      minimum_age: "4",
      maximum_age: "11",
      gender: "Mixed",
      group: "Local authority maintained schools",
      religious_character: "Jewish",
      urban_or_rural: "(England/Wales) Urban city and town",
      rating: "Good",
      latitude: 51.648438,
      longitude: 14.350231,
      partner_providers: [provider],
    )
  end
  let(:non_query_school) do
    create(:placements_school, name: "York Secondary School", latitude: 29.732613, longitude: 105.448063)
  end
  let(:academic_year) { Placements::AcademicYear.current }
  let(:placement) { create(:placement, school: query_school, academic_year:, year_group:) }
  let(:year_group) { nil }

  before do
    query_school
    non_query_school
  end

  describe "#call" do
    it "returns all schools" do
      expect(query.call).to include(query_school)
      expect(query.call).to include(non_query_school)
    end

    context "when filtering by schools I work with" do
      let(:params) { { filters: { schools_i_work_with_ids: [query_school.id] } } }

      it "returns the filtered schools" do
        expect(query.call).to include(query_school)
        expect(query.call).not_to include(non_query_school)
      end
    end

    context "when filtering by name" do
      let(:params) { { filters: { search_by_name: "London" } } }

      it "returns the filtered schools" do
        expect(query.call).to include(query_school)
        expect(query.call).not_to include(non_query_school)
      end
    end

    context "when filtering by subject" do
      let(:placement_subject) { create(:subject) }
      let(:params) { { filters: { subject_ids: [placement_subject.id] } } }

      before do
        placement.update(subject: placement_subject)
      end

      it "returns the filtered schools" do
        expect(query.call).to include(query_school)
        expect(query.call).not_to include(non_query_school)
      end

      context "when searching for an additional subject" do
        let(:additional_subject) { create(:subject, parent_subject: create(:subject)) }
        let(:params) { { filters: { subject_ids: [additional_subject.id] } } }

        before do
          placement.update(additional_subjects: [additional_subject])
        end

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end
    end

    context "when filtering by phase" do
      let(:params) { { filters: { phases: [query_school.phase] } } }

      it "returns the filtered schools" do
        expect(query.call).to include(query_school)
        expect(query.call).not_to include(non_query_school)
      end
    end

    context "when filtering by year group" do
      before { placement }

      let(:year_group) { "year_1" }
      let(:params) { { filters: { year_groups: %w[year_1] } } }

      it "returns the filtered schools" do
        expect(query.call).to include(query_school)
        expect(query.call).not_to include(non_query_school)
      end
    end

    context "when filtering by last offered placements" do
      let(:params) { { filters: { last_offered_placements_academic_year_ids: [academic_year.id] } } }

      before do
        placement.update(academic_year:)
      end

      it "returns the filtered schools" do
        expect(query.call).to include(query_school)
        expect(query.call).not_to include(non_query_school)
      end

      context "when searching for no recent placements and recent placements" do
        let(:params) { { filters: { last_offered_placements_academic_year_ids: [academic_year.id, "never_offered"] } } }

        before do
          placement.update(academic_year:)
        end

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).to include(non_query_school)
        end
      end
    end

    context "when filtering by hosting interest statuses" do
      context "when searching for open hosting interests" do
        let(:params) { { filters: { itt_statuses: %w[open] } } }

        before do
          query_school.hosting_interests.create!(appetite: "interested", academic_year:)
        end

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end

      context "when searching for not open hosting interests" do
        let(:params) { { filters: { itt_statuses: %w[not_open] } } }

        before do
          query_school.hosting_interests.create!(appetite: "not_open", academic_year:)
        end

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end

      context "when searching for unfilled placements" do
        let(:params) { { filters: { itt_statuses: %w[unfilled_placements] } } }

        before do
          query_school.hosting_interests.create!(appetite: "actively_looking", academic_year:)
          create(:placement, school: query_school, academic_year:, provider: nil)
        end

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end

      context "when searching for filled placements" do
        let(:params) { { filters: { itt_statuses: %w[filled_placements] } } }

        before do
          query_school.hosting_interests.create!(appetite: "actively_looking", academic_year:)
          create(:placement, school: query_school, academic_year:, provider: create(:provider))
        end

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).not_to include(non_query_school)
        end
      end

      context "when searching conflicting hosting interests" do
        let(:params) { { filters: { itt_statuses: %w[open not_open] } } }

        before do
          query_school.hosting_interests.create!(appetite: "interested", academic_year:)
          non_query_school.hosting_interests.create!(appetite: "not_open", academic_year:)
        end

        it "returns the filtered schools" do
          expect(query.call).to include(query_school)
          expect(query.call).to include(non_query_school)
        end
      end
    end

    context "when filtering by location" do
      let!(:close_query_school) do
        create(
          :placements_school,
          name: "Bob's Primary School",
          phase: "Primary",
          latitude: 51.651101,
          longitude: 14.347458,
        )
      end

      let!(:far_query_school) do
        create(
          :placements_school,
          name: "Bob's Primary School",
          phase: "Primary",
          latitude: 51.654505,
          longitude: 14.319858,
        )
      end

      let(:location_coordinates) { [query_school.latitude, query_school.longitude] }
      let(:params) { { location_coordinates: } }

      it "returns the filtered schools in order of distance" do
        expect(query.call).to eq([query_school.becomes(School), close_query_school.becomes(School), far_query_school.becomes(School)])
        expect(query.call).not_to include(non_query_school)
      end
    end
  end
end
