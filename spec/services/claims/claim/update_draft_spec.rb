require "rails_helper"

describe Claims::Claim::UpdateDraft do
  subject(:draft_service) { described_class.call(claim:) }

  let!(:previous_revision) { create(:claim, :draft) }
  let!(:claim) { create(:claim, :internal_draft, previous_revision:) }

  it_behaves_like "a service object" do
    let(:params) { { claim: } }
  end

  describe "#call" do
    it "updates draft claim and sets the previous revisions to internal_draft status" do
      expect { draft_service }.to change(claim, :status).from("internal_draft").to("draft")
      expect(claim.previous_revision.status).to eq("internal_draft")
    end
  end
end
