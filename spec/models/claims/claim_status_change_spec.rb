require "rails_helper"

RSpec.describe Claims::ClaimStatusChange, type: :model do
  let(:actor) { create(:claims_support_user) }
  let(:claim) { create(:claim, :draft) }

  it "rejects unattributed status writes, including enum bang methods" do
    expect { claim.submitted! }.to raise_error(Claims::AuditContext::MissingActor)
    expect(claim.reload.status).to eq("draft")
  end

  it "records attributed enum writes and prevents context leaking" do
    Claims::AuditContext.set(actor:) { claim.submitted! }
    expect(claim.status_changes.sole.actor).to eq(actor)
    expect(Claims::AuditContext.actor).to be_nil
    expect { claim.paid! }.to raise_error(Claims::AuditContext::MissingActor)
  end

  it "records a named system operation rather than inventing a user" do
    Claims::AuditContext.set(system_operation: "provider eligibility correction") { claim.invalid_provider! }
    expect(claim.status_changes.sole).to have_attributes(actor_kind: "system", system_operation: "provider eligibility correction", actor: nil)
  end

  it "rejects unsaved or deleted actors" do
    expect {
      Claims::AuditContext.set(actor: build(:claims_user)) { claim.submitted! }
    }.to raise_error(Claims::AuditContext::MissingActor)
  end

  it "does not lose live identity if the actor is subsequently deleted" do
    Claims::AuditContext.set(actor:) { claim.submitted! }
    name = actor.full_name
    actor.destroy!
    expect(claim.status_changes.sole.reload.actor_name).to eq(name)
  end

  it "retains direct creation into the submitted lifecycle" do
    Claims::AuditContext.set(actor:) do
      claim = create(:claim, :submitted)
      expect(claim.status_changes.sole.to_status).to eq("submitted")
    end
  end

  it "does not allow live unknown attribution" do
    event = described_class.new(claim:, to_status: "submitted", sequence: 1, actor_kind: "unknown", occurred_at: Time.current)
    expect(event).not_to be_valid
  end

  it "allows explicitly classified imported unknown attribution" do
    event = described_class.new(claim:, to_status: "submitted", sequence: 1, actor_kind: "unknown", imported: true)
    expect(event).to be_valid
  end

  it "requires a name for live system attribution" do
    event = described_class.new(claim:, to_status: "submitted", sequence: 1, actor_kind: "system", occurred_at: Time.current)
    expect(event).not_to be_valid
    expect(event.errors[:system_operation]).to be_present
  end

  it "requires an actor reference for live user attribution" do
    event = described_class.new(claim:, to_status: "submitted", sequence: 1, actor_kind: "user", occurred_at: Time.current)
    expect(event).not_to be_valid
    expect(event.errors[:actor]).to be_present
  end

  it "does not accept an event without a real transition" do
    event = described_class.new(claim:, from_status: "submitted", to_status: "submitted", sequence: 1, actor_kind: "unknown", imported: true)
    expect(event).not_to be_valid
    expect(event.errors[:to_status]).to be_present
  end

  it "is append only" do
    Claims::AuditContext.set(actor:) { claim.submitted! }
    event = claim.status_changes.sole
    expect { event.update!(to_status: "paid") }.to raise_error(ActiveRecord::ReadOnlyRecord)
    expect { event.destroy! }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end

  it "retains history when a claim is removed through the existing support journey" do
    Claims::AuditContext.set(actor:) { claim.submitted! }
    event = claim.status_changes.sole
    claim_id = claim.id
    claim.destroy!
    expect(event.reload).to have_attributes(claim_id:, to_status: "submitted", actor_name: actor.full_name)
    expect(event.claim).to be_nil
  end

  it "records all non-draft statuses using the same shape" do
    (Claims::Claim.statuses.keys - Claims::Claim::DRAFT_STATUSES.map(&:to_s)).each do |status|
      draft = create(:claim, :draft)
      Claims::AuditContext.set(actor:) { draft.update!(status:) }
      expect(draft.status_changes.sole).to have_attributes(from_status: "draft", to_status: status, actor:)
    end
  end

  it "rejects stale model writes instead of recording a false predecessor" do
    stale = Claims::Claim.find(claim.id)
    Claims::AuditContext.set(actor:) do
      claim.submitted!
      expect { stale.paid! }.to raise_error(ActiveRecord::StaleObjectError)
    end
    expect(claim.reload.status).to eq("submitted")
    expect(claim.status_changes.count).to eq(1)
  end

  it "does not reuse a previous generic audit when field auditing is disabled" do
    Claims::AuditContext.set(actor:) do
      claim.submitted!
      claim.without_auditing { claim.paid! }
    end

    expect(claim.status_changes.order(:sequence).last.legacy_audit_id).to be_nil
  end

  it "recognizes a legacy submitted lifecycle before the backfill has run" do
    legacy_claim = create(:claim, :submitted)
    described_class.where(claim_id: legacy_claim.id).delete_all
    legacy_claim.update_column(:status, "draft")
    Claims::AuditContext.set(actor:) { legacy_claim.internal_draft! }
    expect(legacy_claim.status_changes.sole).to have_attributes(from_status: "draft", to_status: "internal_draft")
  end

  it "enforces named system attribution at the database boundary" do
    attributes = {
      claim_id: claim.id,
      to_status: "submitted",
      actor_kind: "system",
      sequence: 1,
      occurred_at: Time.current,
      system_operation: nil,
    }
    expect {
      described_class.transaction(requires_new: true) { described_class.insert_all!([attributes]) }
    }.to raise_error(ActiveRecord::StatementInvalid, /claim_status_changes_attribution/)
  end
end
