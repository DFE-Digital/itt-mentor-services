require "rails_helper"

RSpec.describe Placements::OrganisationFinder do
  before do
    create(:school, :placements, name: "School London", postcode: "EC12 5BN")
    create(:school, :claims, name: "School not on placements list")
    create(:placements_provider, :university, name: "University of Westminster", postcode: "HA4 9JZ")
    create(:placements_provider, :lead_school, name: "Provider London", postcode: "SE3 5SL")
    create(:provider, :university, name: "Not a placements provider")
    create(:school, :placements, name: "A School", postcode: "HA4 2FW")
    create(:school, :placements, name: "1 Primary", postcode: "SW12 H3B")
  end

  context "with no search or filter" do
    subject(:organisations_finder) { described_class.call }

    it "returns all placement schools and providers, ordered by name" do
      results = organisations_finder
      expect(results.pluck(:content))
        .to eq ["1 Primary SW12 H3B",
                "A School HA4 2FW",
                "Provider London SE3 5SL",
                "School London EC12 5BN",
                "University of Westminster HA4 9JZ"]
    end
  end

  context "with search without filters" do
    describe "search postcode" do
      subject(:organisations_finder) { described_class.call(search_term: "HA4") }

      it "returns a provider and school matching the search term" do
        results = organisations_finder
        expect(results.pluck(:content))
          .to match_array ["A School HA4 2FW", "University of Westminster HA4 9JZ"]
      end
    end

    describe "search name" do
      subject(:organisations_finder) { described_class.call(search_term: "London") }

      it "returns a provider and school with 'London' in the name" do
        results = organisations_finder
        expect(results.pluck(:content))
          .to match_array ["School London EC12 5BN", "Provider London SE3 5SL"]
      end
    end

    describe "search partial name" do
      subject(:organisations_finder) { described_class.call(search_term: "Lond") }

      it "returns a provider and school with 'London' in the name" do
        results = organisations_finder
        expect(results.pluck(:content))
          .to match_array ["School London EC12 5BN", "Provider London SE3 5SL"]
      end
    end
  end

  describe "filters without search" do
    context "with schools only" do
      subject(:organisations_finder) { described_class.call(filters: %w[school]) }

      it "returns only schools ordered by name" do
        results = organisations_finder
        expect(results.pluck(:content)).to eq ["1 Primary SW12 H3B",
                                               "A School HA4 2FW",
                                               "School London EC12 5BN"]
      end
    end

    context "with school and provider" do
      subject(:organisations_finder) { described_class.call(filters: %w[school university]) }

      it "returns only schools and specified provider type" do
        results = organisations_finder
        expect(results.pluck(:content)).to eq ["1 Primary SW12 H3B",
                                               "A School HA4 2FW",
                                               "School London EC12 5BN",
                                               "University of Westminster HA4 9JZ"]
      end
    end
  end

  describe "filters and search" do
    subject(:organisations_finder) { described_class.call(filters: %w[school], search_term: "HA4") }

    it "only returns school (not provider) with the given postcode" do
      results = organisations_finder
      expect(results.pluck(:content)).to eq ["A School HA4 2FW"]
    end
  end
end
