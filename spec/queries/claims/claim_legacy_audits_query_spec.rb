require "rails_helper"

RSpec.describe Claims::ClaimLegacyAuditsQuery do
  subject(:audits) { described_class.call(claim:) }

  let(:claim) { create(:claim, :draft) }

  it "includes exact draft, non-status and associated mentor audits but no other claim's evidence" do
    claim.update!(zendesk_url: "https://example.com/12345")
    mentor_training = create(:mentor_training, claim:)
    mentor_training.update!(hours_completed: 4)
    other_claim = create(:claim, :draft)

    expect(audits).to include(*claim.audits, *mentor_training.audits)
    expect(audits).not_to include(*other_claim.audits)
    expect(audits.find(claim.audits.last.id).attributes).to eq(claim.audits.last.attributes)
  end
end
