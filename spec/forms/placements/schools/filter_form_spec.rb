require "rails_helper"

describe Placements::Schools::FilterForm, type: :model do
  include Rails.application.routes.url_helpers

  let(:provider) { create(:placements_provider) }
  let(:current_academic_year) { Placements::AcademicYear.current }

  describe "#filters_selected?" do
    subject(:filter_form) { described_class.new(provider, params).filters_selected? }

    context "when given schools I work with id params" do
      let(:params) { { schools_i_work_with_ids: %w[school_id] } }

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

    context "when given search by name params" do
      context "when search by name an empty string" do
        let(:params) { { search_by_name: "" } }

        it "return false" do
          expect(filter_form).to be(false)
        end
      end

      context "when search by name a non-empty string" do
        let(:params) { { search_by_name: "Hogwarts" } }

        it "returns true" do
          expect(filter_form).to be(true)
        end
      end
    end

    context "when given phase params" do
      let(:params) { { phases: %w[primary secondary] } }

      it "returns true" do
        expect(filter_form).to be(true)
      end
    end

    context "when given itt status params" do
      let(:params) { { itt_statuses: %w[itt_status] } }

      it "returns true" do
        expect(filter_form).to be(true)
      end
    end

    context "when given last offered placements academic year ids params" do
      let(:params) { { last_offered_placements_academic_year_ids: %w[academic_year_id] } }

      it "returns true" do
        expect(filter_form).to be(true)
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

    it "returns the find index page path" do
      expect(filter_form.clear_filters_path).to eq(placements_provider_find_index_path(provider))
    end
  end

  describe "index_path_without_filter" do
    subject(:filter_form) { described_class.new(provider, params) }

    context "when removing schools I work with id params" do
      let(:params) do
        { schools_i_work_with_ids: %w[school_id_1 school_id_2] }
      end

      it "returns the find index page path without the given schools I work with id param" do
        expect(
          filter_form.index_path_without_filter(
            filter: "schools_i_work_with_ids",
            value: "school_id_1",
          ),
        ).to eq(
          placements_provider_find_index_path(
            provider,
            filters: {
              schools_i_work_with_ids: %w[school_id_2],
            },
          ),
        )
      end
    end

    context "when removing subject id params" do
      let(:params) do
        { subject_ids: %w[subject_id_1 subject_id_2] }
      end

      it "returns the find index page path without the given subject id param" do
        expect(
          filter_form.index_path_without_filter(
            filter: "subject_ids",
            value: "subject_id_1",
          ),
        ).to eq(
          placements_provider_find_index_path(
            provider,
            filters: {
              subject_ids: %w[subject_id_2],
            },
          ),
        )
      end
    end

    context "when removing search location params" do
      let(:params) do
        { search_location: "London" }
      end

      it "returns the find index page path without the given search location param" do
        expect(
          filter_form.index_path_without_filter(
            filter: "search_location",
            value: "London",
          ),
        ).to eq(
          placements_provider_find_index_path(provider),
        )
      end
    end

    context "when removing search by name params" do
      let(:params) do
        { search_by_name: "Hogwarts" }
      end

      it "returns the find index page path without the given search by name param" do
        expect(
          filter_form.index_path_without_filter(
            filter: "search_by_name",
            value: "Hogwarts",
          ),
        ).to eq(
          placements_provider_find_index_path(provider),
        )
      end
    end

    context "when removing phase params" do
      let(:params) do
        { phases: %w[primary secondary] }
      end

      it "returns the find index page path without the given phase param" do
        expect(
          filter_form.index_path_without_filter(
            filter: "phases",
            value: "primary",
          ),
        ).to eq(
          placements_provider_find_index_path(
            provider,
            filters: {
              phases: %w[secondary],
            },
          ),
        )
      end
    end

    context "when removing itt status params" do
      let(:params) do
        { itt_statuses: %w[itt_status itt_status_2] }
      end

      it "returns the find index page path without the given itt status param" do
        expect(
          filter_form.index_path_without_filter(
            filter: "itt_statuses",
            value: "itt_status_2",
          ),
        ).to eq(
          placements_provider_find_index_path(
            provider,
            filters: {
              itt_statuses: %w[itt_status],
            },
          ),
        )
      end
    end

    context "when removing last offered placements academic year ids params" do
      let(:params) do
        { last_offered_placements_academic_year_ids: %w[academic_year_id_1 academic_year_id_2] }
      end

      it "returns the find index page path without the given last offered placements academic year ids param" do
        expect(
          filter_form.index_path_without_filter(
            filter: "last_offered_placements_academic_year_ids",
            value: "academic_year_id_1",
          ),
        ).to eq(
          placements_provider_find_index_path(
            provider,
            filters: {
              last_offered_placements_academic_year_ids: %w[academic_year_id_2],
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
          schools_i_work_with_ids: [],
          subject_ids: [],
          search_location: nil,
          search_by_name: nil,
          phases: [],
          year_groups: [],
          itt_statuses: [],
          last_offered_placements_academic_year_ids: [],
        },
      )
    end
  end

  describe "#schools_i_work_with" do
    it "returns the schools I work with associated with the schools_i_work_with_ids params given" do
      schools = create_list(:placements_school, 2, partner_providers: [provider])

      expect(
        described_class.new(provider, schools_i_work_with_ids: schools.pluck(:id)).schools_i_work_with,
      ).to match_array(School.where(id: schools.pluck(:id)))
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

  describe "#last_offered_placements_academic_years" do
    it "returns the academic years associated with the last_offered_placements_academic_year_ids params given" do
      academic_years = create_list(:placements_academic_year, 2)

      expect(
        described_class.new(provider, last_offered_placements_academic_year_ids: academic_years.pluck(:id)).last_offered_placements_academic_years,
      ).to match_array(academic_years)
    end
  end

  describe "#last_offered_placement_options" do
    context "when placements have been offered previously" do
      let(:previous_academic_year) { Placements::AcademicYear.current.previous }
      let(:placements) { create_list(:placement, 2, academic_year: previous_academic_year) }

      before { placements }

      it "returns the academic years associated with the last_offered_placements_academic_year_ids params given" do
        expect(
          described_class.new(provider).last_offered_placement_options,
        ).to contain_exactly([previous_academic_year.name, previous_academic_year.id], ["No recent placements", "never_offered"])
      end
    end

    context "when no placements have been offered previously" do
      it "returns the 'No recent placements' option" do
        expect(
          described_class.new(provider).last_offered_placement_options,
        ).to contain_exactly(["No recent placements", "never_offered"])
      end
    end
  end

  describe "#primary_selected?" do
    subject(:filter_form) { described_class.new(provider, params) }

    context "when primary is selected" do
      let(:params) { { phases: %w[Primary] } }

      it "returns true" do
        expect(filter_form.primary_selected?).to be(true)
      end
    end

    context "when primary is not selected" do
      let(:params) { { phases: %w[Secondary] } }

      it "returns false" do
        expect(filter_form.primary_selected?).to be(false)
      end
    end
  end

  describe "#secondary_selected?" do
    subject(:filter_form) { described_class.new(provider, params) }

    context "when secondary is selected" do
      let(:params) { { phases: %w[Secondary] } }

      it "returns true" do
        expect(filter_form.secondary_selected?).to be(true)
      end
    end

    context "when secondary is not selected" do
      let(:params) { { phases: %w[Primary] } }

      it "returns false" do
        expect(filter_form.secondary_selected?).to be(false)
      end
    end
  end

  describe "#primary_only?" do
    subject(:filter_form) { described_class.new(provider, params) }

    context "when only primary is selected" do
      let(:params) { { phases: %w[Primary] } }

      it "returns true" do
        expect(filter_form.primary_only?).to be(true)
      end
    end

    context "when secondary is also selected" do
      let(:params) { { phases: %w[Primary Secondary] } }

      it "returns false" do
        expect(filter_form.primary_only?).to be(false)
      end
    end
  end

  describe "#secondary_only?" do
    subject(:filter_form) { described_class.new(provider, params) }

    context "when only secondary is selected" do
      let(:params) { { phases: %w[Secondary] } }

      it "returns true" do
        expect(filter_form.secondary_only?).to be(true)
      end
    end

    context "when primary is also selected" do
      let(:params) { { phases: %w[Primary Secondary] } }

      it "returns false" do
        expect(filter_form.secondary_only?).to be(false)
      end
    end
  end
end
