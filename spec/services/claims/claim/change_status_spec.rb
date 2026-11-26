require "rails_helper"

RSpec.describe Claims::Claim::ChangeStatus do
  let(:claim) { create(:claim, :draft) }
  let(:actor) { create(:claims_user) }

  def change_status(status, **options)
    described_class.call(claim:, attributes: { status: }, actor:, **options)
  end

  it "records submission with its actor atomically" do
    change_status(:submitted)

    event = claim.status_changes.sole
    expect(event).to have_attributes(from_status: "draft", to_status: "submitted", actor:, actor_kind: "user", sequence: 1, imported: false)
    expect(event.actor_name).to eq(actor.full_name)
    expect(event.occurred_at).to be_present
    expect(event.legacy_audit_id).to eq(claim.audits.last.id)
  end

  it "does not record initial draft changes" do
    claim = create(:claim)
    described_class.call(claim:, attributes: { status: :draft }, actor:)
    expect(claim.status_changes).to be_empty
  end

  it "continues recording after a return to draft" do
    change_status(:submitted)
    change_status(:draft)
    change_status(:internal_draft)
    expect(claim.status_changes.order(:sequence).pluck(:to_status)).to eq(%w[submitted draft internal_draft])
  end

  it "reuses a lock only within its transaction and tracks successive changes" do
    claim.with_status_lock do
      change_status(:submitted)
      change_status(:paid)
    end
    expect(Claims::AuditContext.locked_claim).to be_nil
    expect(claim.status_changes.order(:sequence).pluck(:to_status)).to eq(%w[submitted paid])
  end

  it "clears lock context after failure and rejects a deleted actor on a later operation" do
    expect { change_status(:not_a_status) }.to raise_error(ActiveRecord::RecordInvalid)
    expect(Claims::AuditContext.locked_claim).to be_nil
    change_status(:submitted)
    actor.destroy!
    expect { change_status(:paid) }.to raise_error(Claims::AuditContext::MissingActor)
    expect(Claims::AuditContext.locked_claim).to be_nil
    expect(claim.reload.status).to eq("submitted")
  end

  it "does not invent intermediate states for an exceptional paid claim" do
    change_status(:paid)
    expect(claim.status_changes.sole).to have_attributes(from_status: "draft", to_status: "paid")
  end

  it "records a genuine direct creation by a named system operation" do
    new_claim = build(:claim)
    described_class.call(claim: new_claim, attributes: { status: :paid }, system_operation: "seed demo claims")
    expect(new_claim.status_changes.sole).to have_attributes(
      from_status: nil, to_status: "paid", actor_kind: "system", system_operation: "seed demo claims",
    )
  end

  it "does not record an unchanged status or a field-only update" do
    change_status(:submitted)
    expect {
      change_status(:submitted)
      claim.update!(reviewed: true)
    }.not_to change(Claims::ClaimStatusChange, :count)
  end

  it "preserves pending wizard attributes and nested records while locking" do
    provider = create(:claims_provider)
    claim.provider = provider
    training = build(:mentor_training, claim:, provider:)
    claim.mentor_trainings << training
    change_status(:submitted)
    expect(claim.reload.provider).to eq(provider)
    expect(claim.mentor_trainings).to include(training)
  end

  it "records recurring transitions rather than deduplicating status pairs" do
    %i[submitted paid sampling_in_progress paid sampling_in_progress paid].each { |status| change_status(status) }
    expect(claim.status_changes.count).to eq(6)
    expect(claim.status_changes.order(:sequence).pluck(:sequence)).to eq((1..6).to_a)
  end

  it "rejects a stale expected status" do
    change_status(:submitted)
    expect { change_status(:paid, expected_status: :draft) }.to raise_error(Claims::Claim::ChangeStatus::StaleStatus)
    expect(claim.reload.status).to eq("submitted")
  end

  it "checks the caller's observed status before reloading under the lock" do
    stale = Claims::Claim.find(claim.id)
    change_status(:submitted)
    expect {
      described_class.call(claim: stale, attributes: { status: :paid }, actor:)
    }.to raise_error(Claims::Claim::ChangeStatus::StaleStatus)
    expect(claim.reload.status).to eq("submitted")
  end

  it "deduplicates a retried operation without replaying it" do
    change_status(:submitted, operation_id: "submission")
    change_status(:paid)
    expect { change_status(:submitted, operation_id: "submission") }.not_to change(Claims::ClaimStatusChange, :count)
    expect(claim.reload.status).to eq("paid")
  end

  it "rejects reuse of an operation for a different destination" do
    change_status(:submitted, operation_id: "submission")
    expect { change_status(:paid, operation_id: "submission") }.to raise_error(ArgumentError)
  end

  it "rolls back the claim if recording fails" do
    allow(Claims::ClaimStatusChange).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
    expect { change_status(:submitted) }.to raise_error(ActiveRecord::RecordInvalid)
    expect(claim.reload.status).to eq("draft")
  end

  it "rolls back events with the enclosing transaction" do
    claim
    Claims::Claim.transaction do
      change_status(:submitted)
      raise ActiveRecord::Rollback
    end
    expect(claim.reload.status).to eq("draft")
    expect(claim.status_changes).to be_empty
  end

  it "does not record invalid changes" do
    expect { change_status(:not_a_status) }.to raise_error(ActiveRecord::RecordInvalid)
    expect(claim.reload.status).to eq("draft")
    expect(claim.status_changes).to be_empty
  end

  it "retains batch context and reasons" do
    source = create(:claims_payment, claims: [])
    described_class.call(claim:, attributes: { status: :payment_in_progress, unpaid_reason: "Evidence needed" }, actor:, source:)
    expect(claim.status_changes.sole).to have_attributes(source:, details: { "unpaid_reason" => [nil, "Evidence needed"] })
  end
end
