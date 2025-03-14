require "rails_helper"

describe Claims::Support::Claims::FilterForm, type: :model do
  include Rails.application.routes.url_helpers

  let(:index_path) { claims_support_claims_path }

  describe "attributes" do
    it do
      expect(described_class.new).to have_attributes(
        search: nil,
        search_school: nil,
        search_provider: nil,
        "submitted_after(1i)" => nil,
        "submitted_after(2i)" => nil,
        "submitted_after(3i)" => nil,
        "submitted_before(1i)" => nil,
        "submitted_before(2i)" => nil,
        "submitted_before(3i)" => nil,
        school_ids: [],
        provider_ids: [],
        statuses: [],
        academic_year_ids: [],
        index_path: nil,
      )
    end
  end

  describe "#filters_selected?" do
    it "returns true if school_ids present" do
      params = { school_ids: %w[school_id] }
      form = described_class.new(params)

      expect(form.filters_selected?).to be(true)
    end

    it "returns true if provider_ids present" do
      params = { provider_ids: %w[provider_id] }
      form = described_class.new(params)

      expect(form.filters_selected?).to be(true)
    end

    it "returns true if academic_year_ids present" do
      params = { academic_year_ids: %w[academic_year_id] }
      form = described_class.new(params)

      expect(form.filters_selected?).to be(true)
    end

    it "returns true if submitted_after is present" do
      params = {
        "submitted_after(1i)" => "2024",
        "submitted_after(2i)" => "1",
        "submitted_after(3i)" => "2",
      }
      form = described_class.new(params)

      expect(form.filters_selected?).to be(true)
    end

    it "returns true if submitted_before is present" do
      params = {
        "submitted_before(1i)" => "2024",
        "submitted_before(2i)" => "1",
        "submitted_before(3i)" => "2",
      }
      form = described_class.new(params)

      expect(form.filters_selected?).to be(true)
    end

    it "returns true if statuses are present" do
      params = {
        "statuses" => %w[submitted],
      }

      form = described_class.new(params)

      expect(form.filters_selected?).to be(true)
    end

    context "when filters are not present" do
      it "returns false" do
        form = described_class.new({})

        expect(form.filters_selected?).to be(false)
      end
    end
  end

  describe "#index_path_without_filter" do
    it "returns the support claims index path without a filter" do
      params = { school_ids: %w[school_id], index_path: }
      call = described_class.new(params).index_path_without_filter(filter: "school_ids", value: "school_id")

      expect(call).to eq(
        claims_support_claims_path,
      )
    end
  end

  describe "#index_path_without_submitted_dates" do
    context "with submitted_after" do
      it "returns the support claims index path without submitted dates" do
        params = {
          "submitted_after(1i)" => "2024",
          "submitted_after(2i)" => "1",
          "submitted_after(3i)" => "2",
          index_path:,
        }
        call = described_class.new(params).index_path_without_submitted_dates("submitted_after")

        expect(call).to eq(
          claims_support_claims_path,
        )
      end
    end

    context "with submitted_before" do
      it "returns the support claims index path without submitted dates" do
        params = {
          "submitted_before(1i)" => "2024",
          "submitted_before(2i)" => "1",
          "submitted_before(3i)" => "2",
          index_path:,
        }
        call = described_class.new(params).index_path_without_submitted_dates("submitted_before")

        expect(call).to eq(
          claims_support_claims_path,
        )
      end
    end
  end

  describe "#clear_filters_path" do
    it "returns the support claims index path without filters but with search" do
      params = { school_ids: %w[school_id], search: "search", index_path: }
      call = described_class.new(params).clear_filters_path

      expect(call).to eq(
        claims_support_claims_path(
          params: { claims_support_claims_filter_form: { search: "search" } },
        ),
      )
    end

    context "when search param is not present" do
      it "returns the support claims index path without filters and search" do
        params = { school_ids: %w[school_id], index_path: }
        call = described_class.new(params).clear_filters_path

        expect(call).to eq(claims_support_claims_path)
      end
    end
  end

  describe "#clear_search_path" do
    it "returns the support claims index path without search but with filters" do
      params = { school_ids: %w[school_id], search: "search", index_path: }
      call = described_class.new(params).clear_search_path

      expect(call).to eq(
        claims_support_claims_path(
          params: { claims_support_claims_filter_form: { school_ids: %w[school_id] } },
        ),
      )
    end

    context "when filters are not present" do
      it "returns the support claims index path without search and without filters" do
        params = { search: "search", index_path: }
        call = described_class.new(params).clear_search_path

        expect(call).to eq(claims_support_claims_path)
      end
    end
  end

  describe "#schools" do
    it "returns a collection of claims schools based on school_ids param" do
      school = create(:claims_school)
      params = { school_ids: [school.id] }
      call = described_class.new(params).schools

      expect(call).to eq([school])
    end

    context "when school_ids is empty" do
      it "returns empty array" do
        params = { school_ids: [] }
        call = described_class.new(params).schools

        expect(call).to eq([])
      end
    end
  end

  describe "#providers" do
    it "returns a collection of claims providers based on provider_ids param" do
      provider = create(:claims_provider)
      params = { provider_ids: [provider.id] }
      call = described_class.new(params).providers

      expect(call).to eq([provider])
    end

    context "when provider_ids is empty" do
      it "returns empty array" do
        params = { provider_ids: [] }
        call = described_class.new(params).providers

        expect(call).to eq([])
      end
    end
  end

  describe "#academic_years" do
    it "returns a collection of academic years based on academic_year_ids param" do
      academic_year = AcademicYear.first
      params = { academic_year_ids: [academic_year.id] }
      call = described_class.new(params).academic_years

      expect(call).to eq([academic_year])
    end

    context "when academic_year_ids is empty" do
      it "returns empty array" do
        params = { academic_year_ids: [] }
        call = described_class.new(params).academic_years

        expect(call).to eq([])
      end
    end
  end

  describe "#query_params" do
    it "returns the query params meant for searching the database" do
      params = {
        search: "claim_reference",
        search_school: "school_name",
        search_provider: "provider",
        "submitted_after(1i)" => "2024",
        "submitted_after(2i)" => "1",
        "submitted_after(3i)" => "2",
        "submitted_before(1i)" => "2023",
        "submitted_before(2i)" => "1",
        "submitted_before(3i)" => "2",
        school_ids: %w[school_id],
        provider_ids: %w[provider_id],
        statuses: %w[submitted],
        academic_year_ids: %w[academic_year_id],
      }

      call = described_class.new(params).query_params

      expect(call).to eq(
        provider_ids: %w[provider_id],
        school_ids: %w[school_id],
        search: "claim_reference",
        search_provider: "provider",
        search_school: "school_name",
        submitted_after: Date.new(2024, 1, 2),
        submitted_before: Date.new(2023, 1, 2),
        statuses: %w[submitted],
        academic_year_ids: %w[academic_year_id],
      )
    end
  end

  describe "#submitted_after" do
    it "the Submitted after date in Date format" do
      params = {
        "submitted_after(1i)" => "2024",
        "submitted_after(2i)" => "1",
        "submitted_after(3i)" => "2",
      }
      call = described_class.new(params).submitted_after

      expect(call).to eq(Date.new(2024, 1, 2))
    end

    context "when submitted after params are not valid" do
      it "the Submitted after date in Date format" do
        params = {
          "submitted_after(1i)" => "invalid",
        }
        call = described_class.new(params).submitted_after

        expect(call).to be_nil
      end
    end
  end

  describe "#submitted_before" do
    it "the Submitted before date in Date format" do
      params = {
        "submitted_before(1i)" => "2024",
        "submitted_before(2i)" => "1",
        "submitted_before(3i)" => "2",
      }
      call = described_class.new(params).submitted_before

      expect(call).to eq(Date.new(2024, 1, 2))
    end

    context "when submitted before params are not valid" do
      it "the Submitted before date in Date format" do
        params = {
          "submitted_before(1i)" => "invalid",
        }
        call = described_class.new(params).submitted_before

        expect(call).to be_nil
      end
    end
  end
end
