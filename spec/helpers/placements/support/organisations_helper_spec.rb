require "rails_helper"

RSpec.describe Placements::Support::OrganisationsHelper do
  describe "#no_results" do
    context "when search and filters are blank" do
      it "returns no organisations message" do
        expect(no_results).to eq(I18n.t("placements.support.organisations.index.no_organisations"))
      end
    end

    context "when search is blank" do
      it "returns no results with filter message" do
        expect(no_results("", %w[filter])).to eq(I18n.t("no_results_with_filter"))
      end
    end

    context "when filters are blank" do
      it "returns no results message" do
        expect(no_results("search", [])).to eq(I18n.t("no_results", for: "search"))
      end
    end

    context "when search and filters are not blank" do
      it "returns no results with filter and search message" do
        expect(no_results("search", %w[filter])).to eq(I18n.t("no_results_with_filter_and_search", for: "search"))
      end
    end
  end

  describe "#filter_options" do
    it "returns provider types and school" do
      expect(filter_options).to eq(%w[lead_school school scitt university])
    end
  end
end
