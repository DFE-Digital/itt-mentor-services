require "rails_helper"

describe Claims::Providers::Claims::FilterForm, type: :model do
  include Rails.application.routes.url_helpers

  let(:provider) { create(:claims_provider) }
  let(:index_path) { claims_provider_claims_path(provider) }

  describe "attributes" do
    it do
      expect(described_class.new).to have_attributes(
        school_ids: [],
        index_path: nil,
      )
    end
  end

  describe "#filters_selected?" do
    it "returns true if school_ids are present" do
      expect(described_class.new(school_ids: %w[school-id]).filters_selected?).to be(true)
    end

    it "returns false when no filters are present" do
      expect(described_class.new.filters_selected?).to be(false)
    end
  end

  describe "#index_path_without_filter" do
    it "removes a selected school from the generated path" do
      form = described_class.new(index_path:, school_ids: %w[school-id another-school-id])

      expect(form.index_path_without_filter(filter: "school_ids", value: "school-id")).to eq(
        claims_provider_claims_path(
          provider,
          params: { claims_providers_claims_filter_form: { school_ids: %w[another-school-id] } },
        ),
      )
    end
  end

  describe "#clear_filters_path" do
    it "returns the unfiltered provider claims index path" do
      form = described_class.new(index_path:, school_ids: %w[school-id])

      expect(form.clear_filters_path).to eq(claims_provider_claims_path(provider))
    end
  end

  describe "#schools" do
    it "returns the schools for the selected school ids" do
      school = create(:claims_school)
      form = described_class.new(index_path:, school_ids: [school.id])

      expect(form.schools).to eq([school])
    end

    it "returns an empty collection when no schools are selected" do
      expect(described_class.new(index_path:).schools).to eq([])
    end
  end

  describe "#query_params" do
    it "returns the school filters" do
      form = described_class.new(index_path:, school_ids: %w[school-id])

      expect(form.query_params).to eq(
        school_ids: %w[school-id],
      )
    end
  end
end
