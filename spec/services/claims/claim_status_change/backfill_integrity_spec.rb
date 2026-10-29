require "rails_helper"

RSpec.describe Claims::ClaimStatusChange::Backfill do
  let(:claim) { create(:claim) }
  let(:service) { described_class.send(:new) }
  let(:audit) do
    Audited::Audit.create!(
      auditable: claim,
      action: "update",
      version: claim.audits.maximum(:version).to_i + 1,
      audited_changes: { "status" => %w[draft submitted] },
    )
  end
  let(:transition) { Claims::ClaimStatusChange::LegacyAudit.transition_for(audit) }

  it "imports known actor identities exactly, without requiring the actor to still exist" do
    audit.update_columns(user_id: SecureRandom.uuid, user_type: "Claims::SupportUser", username: "Historical actor")

    described_class.call

    event = Claims::ClaimStatusChange.find_by!(legacy_audit_id: audit.id)
    expect(event).to have_attributes(
      actor_kind: "user", actor_id: audit.user_id, actor_type: audit.user_type, actor_name: "Historical actor",
    )
    expect(Claims::ClaimStatusChange::LegacyAudit.event_matches_audit?(event, audit, transition)).to be(true)
  end

  it "rejects mismatched retained events after their claim was deleted" do
    audit
    described_class.call(claim_id: claim.id)
    Claims::ClaimStatusChange.where(claim:).update_all(to_status: "paid")
    claim.delete

    expect { described_class.call(claim_id: claim.id) }
      .to raise_error(described_class::UnclassifiedAuditError, /mismatched/)
  end

  it "handles an empty source dataset without inventing a high-water mark" do
    Audited::Audit.delete_all

    expect(described_class.call).to include(imported_count: 0, high_water_mark: nil, last_audit_id: nil)
  end

  it "recognizes a concurrent successful import after acquiring the claim lock" do
    audit
    described_class.call(claim_id: claim.id)

    expect(service.send(:import_audit!, claim, audit, transition, 1)).to be(false)
  end

  it "rejects a concurrent mismatched import after acquiring the claim lock" do
    audit
    described_class.call(claim_id: claim.id)
    Claims::ClaimStatusChange.where(claim:).update_all(to_status: "paid")

    expect { service.send(:import_audit!, claim, audit, transition, 1) }
      .to raise_error(described_class::UnclassifiedAuditError, /mismatched/)
  end

  it "recognizes a matching event after a uniqueness conflict" do
    audit
    described_class.call(claim_id: claim.id)
    allow(claim).to receive(:with_lock).and_raise(ActiveRecord::RecordNotUnique)

    expect(service.send(:import_audit!, claim, audit, transition, 1)).to be(false)
  end

  it "rejects a mismatched event after a uniqueness conflict" do
    audit
    described_class.call(claim_id: claim.id)
    Claims::ClaimStatusChange.where(claim:).update_all(to_status: "paid")
    allow(claim).to receive(:with_lock).and_raise(ActiveRecord::RecordNotUnique)

    expect { service.send(:import_audit!, claim, audit, transition, 1) }
      .to raise_error(described_class::UnclassifiedAuditError, /mismatched/)
  end

  it "classifies a claim deleted between lookup and lock acquisition" do
    audit
    claim.delete
    allow(claim).to receive(:with_lock).and_raise(ActiveRecord::RecordNotFound)

    expect(service.send(:import_audit!, claim, audit, transition, 1)).to eq(:orphaned)
  end

  it "does not swallow an unrelated record lookup failure while the claim still exists" do
    audit
    allow(claim).to receive(:with_lock).and_raise(ActiveRecord::RecordNotFound)

    expect { service.send(:import_audit!, claim, audit, transition, 1) }
      .to raise_error(ActiveRecord::RecordNotFound)
  end

  it "reports imports won by another writer and claims deleted during import" do
    audit
    allow(service).to receive(:import_audit!).and_return(false)

    expect(service.call).to include(imported_count: 0, already_present_count: 1)

    allow(service).to receive(:import_audit!).and_return(:orphaned)

    expect(service.call[:classified_gaps]).to include("orphaned_status_audit" => 1)
  end
end
