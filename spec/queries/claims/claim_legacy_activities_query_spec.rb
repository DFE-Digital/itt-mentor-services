require "rails_helper"

RSpec.describe Claims::ClaimLegacyActivitiesQuery do
  subject(:activities) { described_class.call(claim:) }

  let(:claim) { create(:claim, :draft) }

  it "retains original claim activities and includes only sources explicitly linked to this claim" do
    direct = create(:claim_activity, action: :rejected_by_payer, record: claim)
    response = create(:claims_payment_response)
    linked = create(:claim_activity, action: :payment_response_uploaded, record: response)
    unrelated = create(:claim_activity, action: :payment_response_uploaded, record: create(:claims_payment_response))
    Claims::ClaimStatusChange.create!(
      claim:, source: response, from_status: "submitted", to_status: "paid",
      actor_kind: "unknown", sequence: 1, imported: true
    )

    expect(activities).to contain_exactly(direct, linked)
    expect(activities).not_to include(unrelated)
  end

  it "does not duplicate operational evidence already linked by a batch relation" do
    payment = create(:claims_payment, claims: [claim])
    activity = create(:claim_activity, action: :payment_request_delivered, record: payment)
    Claims::ClaimStatusChange.create!(
      claim:, source: payment, from_status: "submitted", to_status: "payment_in_progress",
      actor_kind: "unknown", sequence: 1, imported: true
    )

    expect(activities).to contain_exactly(activity)
  end
end
