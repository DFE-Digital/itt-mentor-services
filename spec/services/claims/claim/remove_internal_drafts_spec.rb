require "rails_helper"

describe Claims::Claim::RemoveInternalDrafts do
  subject(:service) { described_class.call }

  let!(:draft_claim) { create(:claim, status: :draft) }
  let!(:active_internal_draft_claim) { create(:claim, status: :internal_draft) }
  let!(:submitted_claim) { create(:claim, status: :submitted) }

  it_behaves_like "a service object"

  describe "#call" do
    it "removes internal draft claims that haven't changed in at least 24 hours" do
      create(:claim, status: :internal_draft, updated_at: 1.day.ago)

      expect { service }.to change(Claims::Claim, :count).from(4).to(3)
      expect(Claims::Claim.all).to eq(
        [draft_claim, active_internal_draft_claim, submitted_claim],
      )
    end
  end
end
