require "rails_helper"

describe Placements::Placements::FilterForm, type: :model do
  include Rails.application.routes.url_helpers

  let(:provider) { create(:placements_provider) }

  describe "#filters_selected?" do
    subject(:filter_form) { described_class.new(params).filters_selected? }

    context "when given only available placements params" do
      let(:params) { { only_available_placements: true } }

      it "returns true" do
        expect(filter_form).to eq(true)
      end
    end

    context "when given school id params" do
      let(:params) { { school_ids: %w[school_id] } }

      it "returns true" do
        expect(filter_form).to eq(true)
      end
    end

    context "when given subject id params" do
      let(:params) { { subject_ids: %w[subject_id] } }

      it "returns true" do
        expect(filter_form).to eq(true)
      end
    end

    context "when given establishment group params" do
      let(:params) { { establishment_groups: %w[Colleges] } }

      it "returns true" do
        expect(filter_form).to eq(true)
      end
    end

    context "when given partner school params" do
      let(:params) { { only_partner_schools: true } }

      it "returns true" do
        expect(filter_form).to eq(true)
      end
    end

    context "when given no params" do
      let(:params) { {} }

      it "returns false" do
        expect(filter_form).to eq(false)
      end
    end
  end

  describe "#clear_filters_path" do
    subject(:filter_form) { described_class.new }

    it "returns the placements index page path" do
      expect(filter_form.clear_filters_path).to eq(
        placements_placements_path,
      )
    end
  end

  describe "index_path_without_filter" do
    subject(:filter_form) { described_class.new(params) }

    context "when removing available params" do
      let(:params) do
        { only_available_placements: true }
      end

      it "returns the placements index page path without the given available param" do
        expect(
          filter_form.index_path_without_filter(
            provider:,
            filter: "only_available_placements",
            value: true,
          ),
        ).to eq(
          placements_provider_placements_path(provider),
        )
      end
    end

    context "when removing school id params" do
      let(:params) do
        { school_ids: %w[school_id_1 school_id_2] }
      end

      it "returns the placements index page path without the given school id param" do
        expect(
          filter_form.index_path_without_filter(
            provider:,
            filter: "school_ids",
            value: "school_id_1",
          ),
        ).to eq(
          placements_placements_path(filters: {
            school_ids: %w[school_id_2],
          }),
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
            provider:,
            filter: "only_partner_schools",
            value: false,
          ),
        ).to eq(
          placements_placements_path(filters: {}),
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
            provider:,
            filter: "subject_ids",
            value: "subject_id_1",
          ),
        ).to eq(
          placements_placements_path(filters: {
            subject_ids: %w[subject_id_2],
          }),
        )
      end
    end

    context "when removing establishment group params" do
      let(:params) do
        { establishment_groups: ["Academies", "Independent schools"] }
      end

      it "returns the placements index page path without the given establishment group param" do
        expect(
          filter_form.index_path_without_filter(
            provider:,
            filter: "establishment_groups",
            value: "Independent schools",
          ),
        ).to eq(
          placements_placements_path(filters: {
            establishment_groups: %w[Academies],
          }),
        )
      end
    end
  end

  describe "#query_params" do
    it "returns { only_partner_schools: false, school_ids: [], subject_ids: [], establishment_groups: [] }" do
      expect(described_class.new.query_params).to eq(
        {
          school_ids: [],
          only_partner_schools: false,
          establishment_groups: [],
          subject_ids: [],
          only_available_placements: false,
        },
      )
    end
  end

  describe "#schools" do
    it "returns the schools associated with the school_id params given" do
      schools = create_list(:school, 2)

      expect(
        described_class.new(school_ids: schools.pluck(:id)).schools,
      ).to match_array(schools)
    end
  end

  describe "#subjects" do
    it "returns the subjects associated with the subject_id params given" do
      subjects = create_list(:subject, 2)

      expect(
        described_class.new(subject_ids: subjects.pluck(:id)).subjects,
      ).to match_array(subjects)
    end
  end
end
