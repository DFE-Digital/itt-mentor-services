require "rails_helper"

describe Placements::Placements::FilterForm, type: :model do
  include Rails.application.routes.url_helpers

  let(:provider) { create(:placements_provider) }

  describe "#filters_selected?" do
    subject(:filter_form) { described_class.new(params).filters_selected? }

    context "when given available params" do
      let(:params) { { available: %w[true] } }

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

    context "when given partner school params" do
      let(:params) { { partner_school_ids: %w[partner_school_id] } }

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

    context "when removing available params" do
      let(:params) do
        { available: %w[true] }
      end

      it "returns the placements index page path without the given available param" do
        expect(
          filter_form.index_path_without_filter(
            provider:,
            filter: "available",
            value: "true",
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
          placements_provider_placements_path(provider, filters: {
            school_ids: %w[school_id_2],
          }),
        )
      end
    end

    context "when removing partner school id params" do
      let(:params) do
        { partner_school_ids: %w[school_id_1 school_id_2] }
      end

      it "returns the placements index page path without the given school id param" do
        expect(
          filter_form.index_path_without_filter(
            provider:,
            filter: "partner_school_ids",
            value: "school_id_1",
          ),
        ).to eq(
          placements_provider_placements_path(provider, filters: {
            partner_school_ids: %w[school_id_2],
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

    context "when removing school type params" do
      let(:params) do
        { school_types: ["Free school", "Community school"] }
      end

      it "returns the placements index page path without the given school type param" do
        expect(
          filter_form.index_path_without_filter(
            provider:,
            filter: "school_types",
            value: "Free school",
          ),
        ).to eq(
          placements_provider_placements_path(provider, filters: {
            school_types: ["Community school"],
          }),
        )
      end
    end
  end

  describe "#query_params" do
    it "returns { partner_school_ids: [], school_ids: [], subject_ids: [], school_types: [] }" do
      expect(described_class.new.query_params).to eq(
        {
          school_ids: [],
          partner_school_ids: [],
          school_types: [],
          subject_ids: [],
          available: [],
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

  describe "#partner_schools" do
    it "returns the partner schools associated with the partner_school_id params given" do
      schools = create_list(:school, 2)
      provider.partner_schools << schools

      expect(
        described_class.new(partner_school_ids: schools.pluck(:id)).partner_schools,
      ).to match_array(schools)
    end
  end
end
