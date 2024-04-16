require "rails_helper"

describe Placements::Placements::FilterForm, type: :model do
  include Rails.application.routes.url_helpers

  let(:provider) { create(:placements_provider) }

  describe "#filters_selected?" do
    subject(:filter_form) { described_class.new(params).filters_selected? }

    context "when given school phase params" do
      let(:params) { { school_phases: %w[Primary] } }

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

    context "when given school type params" do
      let(:params) { { school_types: %w[Miscellaneous] } }

      it "returns true" do
        expect(filter_form).to eq(true)
      end
    end

    context "when given gender params" do
      let(:params) { { genders: %w[Mixed] } }

      it "returns true" do
        expect(filter_form).to eq(true)
      end
    end

    context "when given religious character params" do
      let(:params) { { religious_characters: %w[Jewish] } }

      it "returns true" do
        expect(filter_form).to eq(true)
      end
    end

    context "when given ofsted rating params" do
      let(:params) { { ofsted_ratings: %w[Good] } }

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
      expect(filter_form.clear_filters_path(provider)).to eq(
        placements_provider_placements_path(provider),
      )
    end
  end

  describe "index_path_without_filter" do
    subject(:filter_form) { described_class.new(params) }

    context "when removing school phase params" do
      let(:params) do
        { school_phases: %w[Primary Secondary] }
      end

      it "returns the placements index page path without the given school phase param" do
        expect(
          filter_form.index_path_without_filter(
            provider:,
            filter: "school_phases",
            value: "Primary",
          ),
        ).to eq(
          placements_provider_placements_path(provider, filters: {
            school_phases: %w[Secondary],
          }),
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
          placements_provider_placements_path(provider, filters: {
            school_ids: %w[school_id_2],
          }),
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
          placements_provider_placements_path(provider, filters: {
            subject_ids: %w[subject_id_2],
          }),
        )
      end
    end
  end

  describe "#phases" do
    it "returns [Primary, Secondary]" do
      expect(described_class.new.phases).to eq(
        %w[Primary Secondary],
      )
    end
  end

  describe "#query_params" do
    it "returns { school_phases: [], school_ids: [], subject_ids: [] }" do
      expect(described_class.new.query_params).to eq(
        {
          genders: [],
          ofsted_ratings: [],
          religious_characters: [],
          school_ids: [],
          school_phases: [],
          school_types: [],
          subject_ids: [],
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
