require "rails_helper"

RSpec.describe Claims::Providers::ClaimsQuery do
  subject(:claims_query) { described_class.call(claims:, params:) }

  let(:params) { {} }
  let(:school_1) { create(:claims_school) }
  let(:school_2) { create(:claims_school) }

  let(:claim_in_collection_and_school_1) { create(:claim, :submitted, school: school_1) }
  let(:claim_in_collection_and_school_2) { create(:claim, :submitted, school: school_2) }
  let(:claim_outside_collection_and_school_1) { create(:claim, :submitted, school: school_1) }

  let(:claims) do
    Claims::Claim.where(id: [claim_in_collection_and_school_1.id, claim_in_collection_and_school_2.id])
  end

  describe "#call" do
    it "returns the given claims collection when no school filter is provided" do
      expect(claims_query).to contain_exactly(claim_in_collection_and_school_1, claim_in_collection_and_school_2)
    end

    context "when school_ids are provided" do
      let(:params) { { school_ids: [school_1.id] } }

      it "filters the given claims collection by school" do
        expect(claims_query).to contain_exactly(claim_in_collection_and_school_1)
      end

      it "does not include matching claims outside the given claims collection" do
        expect(claims_query).not_to include(claim_outside_collection_and_school_1)
      end
    end

    context "when school_ids are provided with school IDs" do
      let(:params) { { school_ids: [school_2.id] } }

      it "filters by the provided school IDs" do
        expect(claims_query).to contain_exactly(claim_in_collection_and_school_2)
      end
    end

    context "when claims have different statuses" do
      let(:sampling_in_progress_claim) { create(:claim, :submitted, status: :sampling_in_progress, school: school_1) }
      let(:sampling_provider_not_approved_claim) { create(:claim, :submitted, status: :sampling_provider_not_approved, school: school_1) }
      let(:paid_claim) { create(:claim, :submitted, status: :paid, school: school_1) }
      let(:submitted_claim) { create(:claim, :submitted, status: :submitted, school: school_1) }

      let(:claims) do
        Claims::Claim.where(
          id: [
            submitted_claim.id,
            paid_claim.id,
            sampling_provider_not_approved_claim.id,
            sampling_in_progress_claim.id,
          ],
        )
      end

      it "orders claims by priority" do
        expect(claims_query).to eq(
          [
            sampling_in_progress_claim,
            sampling_provider_not_approved_claim,
            paid_claim,
            submitted_claim,
          ],
        )
      end
    end
  end
end
