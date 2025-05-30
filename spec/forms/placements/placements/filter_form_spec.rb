require "rails_helper"

describe Placements::Placements::FilterForm, type: :model do
  include Rails.application.routes.url_helpers

  let(:provider) { create(:placements_provider) }
  let(:current_academic_year) { Placements::AcademicYear.current }

  describe "#filters_selected?" do
    subject(:filter_form) { described_class.new(provider, params).filters_selected? }

    context "when given school id params" do
      let(:params) { { school_ids: %w[school_id] } }

      it "returns true" do
        expect(filter_form).to be(true)
      end
    end

    context "when given subject id params" do
      let(:params) { { subject_ids: %w[subject_id] } }

      it "returns true" do
        expect(filter_form).to be(true)
      end
    end

    context "when given term id params" do
      let(:params) { { term_ids: %w[term_id] } }

      it "returns true" do
        expect(filter_form).to be(true)
      end
    end

    context "when given phase params" do
      let(:params) { { phases: %w[primary secondary] } }

      it "returns true" do
        expect(filter_form).to be(true)
      end
    end

    context "when given year group params" do
      let(:params) { { year_groups: %w[year_group] } }

      it "returns true" do
        expect(filter_form).to be(true)
      end
    end

    context "when given partner school params" do
      context "when only partner schools is true" do
        let(:params) { { only_partner_schools: true } }

        it "returns true" do
          expect(filter_form).to be(true)
        end
      end

      context "when only partner schools is false" do
        let(:params) { { only_partner_schools: false } }

        it "returns true" do
          expect(filter_form).to be(false)
        end
      end
    end

    context "when given search location params" do
      context "when search location an empty string" do
        let(:params) { { search_location: "" } }

        it "return false" do
          expect(filter_form).to be(false)
        end
      end

      context "when search location not an empty string" do
        let(:params) { { search_location: "London" } }

        it "return true" do
          expect(filter_form).to be(true)
        end
      end
    end

    context "when given no params" do
      let(:params) { {} }

      it "returns false" do
        expect(filter_form).to be(false)
      end
    end
  end

  describe "#clear_filters_path" do
    subject(:filter_form) { described_class.new(provider) }

    it "returns the placements index page path" do
      expect(filter_form.clear_filters_path).to eq(
        placements_provider_placements_path(
          provider,
          filters: {
            placements_to_show: "available_placements",
            academic_year_id: current_academic_year.id,
          },
        ),
      )
    end
  end

  describe "index_path_without_filter" do
    subject(:filter_form) { described_class.new(provider, params) }

    context "when removing school id params" do
      let(:params) do
        { school_ids: %w[school_id_1 school_id_2] }
      end

      it "returns the placements index page path without the given school id param" do
        expect(
          filter_form.index_path_without_filter(
            filter: "school_ids",
            value: "school_id_1",
          ),
        ).to eq(
          placements_provider_placements_path(
            provider,
            filters: {
              placements_to_show: "available_placements",
              academic_year_id: current_academic_year.id,
              school_ids: %w[school_id_2],
            },
          ),
        )
      end
    end

    context "when removing the partner schools filter" do
      let(:params) do
        { only_partner_schools: true }
      end

      it "returns the placements index page path without the given school id param" do
        expect(
          filter_form.index_path_without_filter(
            filter: "only_partner_schools",
            value: false,
          ),
        ).to eq(
          placements_provider_placements_path(
            provider,
            filters: {
              placements_to_show: "available_placements",
              academic_year_id: current_academic_year.id,
            },
          ),
        )
      end
    end

    context "when removing subject id params" do
      let(:params) do
        { subject_ids: %w[subject_id_1 subject_id_2] }
      end

      it "returns the placements index page path without the given subject id param" do
        expect(
          filter_form.index_path_without_filter(
            filter: "subject_ids",
            value: "subject_id_1",
          ),
        ).to eq(
          placements_provider_placements_path(
            provider,
            filters: {
              placements_to_show: "available_placements",
              academic_year_id: current_academic_year.id,
              subject_ids: %w[subject_id_2],
            },
          ),
        )
      end
    end

    context "when removing term id params" do
      let(:params) do
        { term_ids: %w[term_id_1 term_id_2] }
      end

      it "returns the placements index page path without the given term id param" do
        expect(
          filter_form.index_path_without_filter(
            filter: "term_ids",
            value: "term_id_1",
          ),
        ).to eq(
          placements_provider_placements_path(
            provider,
            filters: {
              placements_to_show: "available_placements",
              academic_year_id: current_academic_year.id,
              term_ids: %w[term_id_2],
            },
          ),
        )
      end
    end

    context "when removing phase params" do
      let(:params) do
        { phases: %w[primary secondary] }
      end

      it "returns the placements index page path without the given phase param" do
        expect(
          filter_form.index_path_without_filter(
            filter: "phases",
            value: "primary",
          ),
        ).to eq(
          placements_provider_placements_path(
            provider,
            filters: {
              placements_to_show: "available_placements",
              academic_year_id: current_academic_year.id,
              phases: %w[secondary],
            },
          ),
        )
      end
    end

    context "when removing year group params" do
      let(:params) do
        { year_groups: %w[year_group_1 year_group_2] }
      end

      it "returns the placements index page path without the given year group param" do
        expect(
          filter_form.index_path_without_filter(
            filter: "year_groups",
            value: "year_group_1",
          ),
        ).to eq(
          placements_provider_placements_path(
            provider,
            filters: {
              placements_to_show: "available_placements",
              academic_year_id: current_academic_year.id,
              year_groups: %w[year_group_2],
            },
          ),
        )
      end
    end
  end

  describe "#query_params" do
    it "returns the expected result" do
      expect(described_class.new(provider).query_params).to eq(
        {
          placements_to_show: "available_placements",
          academic_year_id: current_academic_year.id,
          school_ids: [],
          only_partner_schools: false,
          search_location: nil,
          subject_ids: [],
          term_ids: [],
          phases: [],
          year_groups: [],
        },
      )
    end
  end

  describe "#schools" do
    it "returns the schools associated with the school_id params given" do
      schools = create_list(:school, 2)

      expect(
        described_class.new(provider, school_ids: schools.pluck(:id)).schools,
      ).to match_array(schools)
    end
  end

  describe "#subjects" do
    it "returns the subjects associated with the subject_id params given" do
      subjects = create_list(:subject, 2)

      expect(
        described_class.new(provider, subject_ids: subjects.pluck(:id)).subjects,
      ).to match_array(subjects)
    end
  end

  describe "#terms" do
    it "returns the terms associated with the term_id params given" do
      terms = create_list(:placements_term, 2, :spring)

      expect(
        described_class.new(provider, term_ids: terms.pluck(:id)).terms,
      ).to match_array(terms)
    end
  end

  describe "#primary_selected?" do
    subject(:filter_form) { described_class.new(provider, params).primary_selected? }

    context "when primary is included in the phases param" do
      let(:params) { { phases: %w[primary] } }

      it "returns true" do
        expect(filter_form).to be(true)
      end
    end
  end

  describe "#secondary_selected?" do
    subject(:filter_form) { described_class.new(provider, params).secondary_selected? }

    context "when secondary is included in the phases param" do
      let(:params) { { phases: %w[secondary] } }

      it "returns true" do
        expect(filter_form).to be(true)
      end
    end
  end
end
