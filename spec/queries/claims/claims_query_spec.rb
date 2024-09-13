require "rails_helper"

describe Claims::ClaimsQuery do
  subject(:claims_query) { described_class.call(params:) }

  let(:params) { {} }

  describe "#call" do
    it "returns all visible claims, ordered by created at date descending" do
      _internal_claim = create(:claim)
      _draft_claim = create(:claim, :draft, created_at: Date.parse("29 March 2024"))
      submitted_claim = create(:claim, :submitted, created_at: Date.parse("28 March 2024"))

      expect(claims_query).to eq([submitted_claim])
    end

    context "when given a search query" do
      let(:params) { { search: "1234" } }

      it "filters the results by provided school ids" do
        claim_with_partial_reference = create(:claim, :submitted, reference: "12345678")
        _claim_without_partial_reference = create(:claim, :submitted, reference: "87654321")

        expect(claims_query).to contain_exactly(claim_with_partial_reference)
      end
    end

    context "when given school ids" do
      let(:school) { create(:claims_school) }
      let(:params) { { school_ids: [school.id] } }

      it "filters the results by provided school ids" do
        claim_belonging_to_filtered_school = create(:claim, :submitted, school:)
        _claim_not_belonging_to_filtered_school = create(:claim, :submitted)

        expect(claims_query).to contain_exactly(claim_belonging_to_filtered_school)
      end
    end

    context "when given provider ids" do
      let(:provider) { create(:claims_provider) }
      let(:params) { { provider_ids: [provider.id] } }

      it "filters the results by provided provider ids" do
        claim_belonging_to_filtered_provider = create(:claim, :submitted, provider:)
        _claim_not_belonging_to_filtered_provider = create(:claim, :submitted)

        expect(claims_query).to contain_exactly(claim_belonging_to_filtered_provider)
      end
    end

    context "when given academic year ids" do
      let(:academic_year) { build(:academic_year, starts_on: Date.parse("1 September 2001"), ends_on: Date.parse("31 August 2002"), name: "2001 to 2002") }
      # The current claim window gets chosen by default for created claims, so we need to create one in the past
      let(:claim_window) { build(:claim_window, academic_year:, starts_on: 2.weeks.ago, ends_on: 1.week.ago) }
      let(:params) { { academic_year_ids: [academic_year.id] } }

      it "filters the results by provided academic year ids" do
        claim_belonging_to_filtered_academic_year = create(:claim, :submitted, claim_window:)
        _claim_not_belonging_to_filtered_academic_year = create(:claim, :submitted)

        expect(claims_query).to contain_exactly(claim_belonging_to_filtered_academic_year)
      end
    end

    context "when given submitted_after" do
      let(:params) { { submitted_after: 2.days.ago } }

      it "filters the results by provided provider ids" do
        expected_claim = create(:claim, :submitted, submitted_at: 1.day.ago)
        _unexpected_claim = create(:claim, :submitted, submitted_at: 3.days.ago)

        expect(claims_query).to contain_exactly(expected_claim)
      end
    end

    context "when given submitted_before" do
      let(:params) { { submitted_before: 2.days.ago } }

      it "filters the results by provided provider ids" do
        expected_claim = create(:claim, :submitted, submitted_at: 3.days.ago)
        _unexpected_claim = create(:claim, :submitted, submitted_at: 1.day.ago)

        expect(claims_query).to contain_exactly(expected_claim)
      end
    end

    context "when given statuses" do
      let(:params) { { statuses: %w[submitted] } }

      it "filters the results by status" do
        _internal_claim = create(:claim)
        _draft_claim = create(:claim, :draft)
        expected_claim = create(:claim, :submitted)
        # TODO: Add unexpected claim with a different status, once additional statuses have been added.

        expect(claims_query).to contain_exactly(expected_claim)
      end
    end
  end
end
