require "rails_helper"

RSpec.describe "Claim lifecycle auditing", type: :job do
  include ActiveJob::TestHelper

  let(:actor) { create(:claims_support_user) }

  it "attributes school submission without relying on an HTTP request" do
    claim = create(:claim, :draft)
    user = create(:claims_user)
    Claims::Claim::Submit.call(claim:, user:)
    expect(claim.status_changes.sole).to have_attributes(actor: user, to_status: "submitted")
  end

  it "attributes exceptional support submission" do
    claim = create(:claim, :draft)
    Claims::Claim::SubmitOnBehalfOfSchool.call(claim:, support_user: actor, status: :paid, paid_to_la: false, date_paid: Time.current)
    expect(claim.status_changes.sole).to have_attributes(actor:, from_status: "draft", to_status: "paid")
  end

  it "links payment request transitions to the file-bearing batch" do
    claim = create(:claim, :submitted)
    Claims::Payment::CreateAndDeliver.call(current_user: actor, claim_window: claim.claim_window)
    expect(claim.status_changes.order(:sequence).last).to have_attributes(actor:, to_status: "payment_in_progress", source: Claims::Payment.last)
  end

  it "links provider-specific sampling transitions to their source" do
    claim = create(:claim, :paid)
    Claims::Sampling::CreateAndDeliver.call(current_user: actor, claims: Claims::Claim.where(id: claim.id), csv_data: [{ id: claim.id, sampling_reason: "Check" }])
    expect(claim.status_changes.order(:sequence).last).to have_attributes(actor:, to_status: "sampling_in_progress", source: claim.provider_samplings.sole)
  end

  it "links clawback request transitions to the exported batch" do
    claim = create(:claim, :submitted, status: :clawback_requested)
    Claims::Clawback::CreateAndDeliver.call(current_user: actor)
    expect(claim.status_changes.order(:sequence).last).to have_attributes(actor:, to_status: "clawback_in_progress", source: Claims::Clawback.last)
  end

  it "retains payer upload attribution through serialized child jobs and retries" do
    claim = create(:claim, :payment_in_progress)
    response = create(:claims_payment_response, user: actor)
    details = [{ id: claim.id, status: "unpaid", unpaid_reason: "Bank details" }]

    perform_enqueued_jobs do
      Claims::Payment::UpdateCollectionWithPayerResponseJob.perform_later(details, response:)
    end
    event = claim.status_changes.order(:sequence).last
    expect(event).to have_attributes(actor:, source: response, to_status: "payment_information_requested")
    expect {
      Claims::Payment::UpdateClaimWithPayerResponseJob.perform_now(details.first, response:)
    }.not_to change(Claims::ClaimStatusChange, :count)
    expect {
      Claims::Payment::UpdateClaimWithPayerResponseJob.perform_now(details.first.merge(status: "paid"), response:)
    }.to raise_error(ArgumentError, "Response already recorded a different status")
  end

  it "retains clawback upload attribution and rejects stale jobs" do
    claim = create(:claim, :submitted, status: :clawback_in_progress)
    response = create(:clawback, claims: [claim])
    perform_enqueued_jobs do
      Claims::Clawback::UpdateCollectionWithESFAResponseJob.perform_later([claim.id], response:, actor:)
    end
    expect(claim.status_changes.order(:sequence).last).to have_attributes(actor:, source: response, to_status: "clawback_complete")
    expect {
      Claims::Clawback::UpdateClaimWithESFAResponseJob.perform_now(claim, response:, actor:)
    }.not_to change(Claims::ClaimStatusChange, :count)
  end
end
