require "rails_helper"

describe Claims::Claim::CreateRevision do
  subject(:service) { described_class.call(claim:) }

  let!(:claim) { create(:claim, reference: nil, status: :internal_draft, school:) }
  let(:school) { create(:claims_school, urn: "1234") }

  it_behaves_like "a service object" do
    let(:params) { { claim: } }
  end

  describe "#call" do
    it "creates a revision of the claim, with associations" do
      anne = create(:claims_user, :anne)
      claim = create(:claim, :draft, submitted_by: anne, created_by: anne)
      attributes = claim.attributes.except(
        "id",
        "created_at",
        "updated_at",
        "status",
        "previous_revision_id",
      ).keys
      revision = described_class.call(claim:)

      expect(revision.mentor_trainings).to eq(claim.mentor_trainings)
      expect(revision.previous_revision_id).to eq(claim.id)
      expect(revision.status).to eq("internal_draft")

      attributes.each do |attribute|
        expect(revision.public_send(attribute)).to eq(claim.public_send(attribute))
      end
    end
  end
end
