require "rails_helper"

describe Claims::ClaimsQuery do
  subject(:claims_query) { described_class.call(params:) }

  let(:params) { {} }

  describe "#call" do
    it "returns all visible claims, ordered by created at date descending" do
      _internal_claim = create(:claim)
      draft_claim = create(:claim, :draft, created_at: Date.parse("29 March 2024"))
      submitted_claim = create(:claim, :submitted, created_at: Date.parse("28 March 2024"))

      expect(claims_query).to eq([draft_claim, submitted_claim])
    end

    context "when given school ids" do
      let(:school) { create(:claims_school) }
      let(:params) { { school_ids: [school.id] } }

      it "filters the results by provided school ids" do
        claim_belonging_to_filtered_school = create(:claim, :submitted, school:)
        _claim_not_belonging_to_filtered_school = create(:claim, :submitted)

        expect(claims_query).to match_array([claim_belonging_to_filtered_school])
      end
    end

    context "when given provider ids" do
      let(:provider) { create(:claims_provider) }
      let(:params) { { provider_ids: [provider.id] } }

      it "filters the results by provided provider ids" do
        claim_belonging_to_filtered_provider = create(:claim, :submitted, provider:)
        _claim_not_belonging_to_filtered_provider = create(:claim, :submitted)

        expect(claims_query).to match_array([claim_belonging_to_filtered_provider])
      end
    end
  end
end
