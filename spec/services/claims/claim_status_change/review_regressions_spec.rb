require "rails_helper"

RSpec.describe "Claim audit review regressions" do
  let(:actor) { create(:claims_support_user) }

  it "includes associated audits newer than the last claim audit in the baseline" do
    claim = create(:claim, :draft)
    training = create(:mentor_training, claim:, hours_completed: 1)
    training.update!(hours_completed: training.hours_completed + 1)
    latest = training.audits.order(:id).last

    baseline = Claims::ClaimStatusChange::Backfill.call(claim_id: claim.id, dry_run: true)
    expect(baseline[:high_water_mark]).to be >= latest.id
    final_page = Claims::ClaimStatusChange::Backfill.call(
      claim_id: claim.id, after_audit_id: claim.audits.maximum(:id), high_water_mark: baseline[:high_water_mark],
    )
    expect(final_page[:last_audit_id]).to eq(baseline[:high_water_mark])
    latest.update_column(:comment, "Changed after baseline")

    expect {
      Claims::ClaimStatusChange::Reconcile.call(claim_id: claim.id, baseline:)
    }.to raise_error(Claims::ClaimStatusChange::Reconcile::Failure, /source checksum/)
  end

  it "retains draft-to-draft transitions after submission when resuming a backfill page" do
    claim = create(:claim, :draft)
    Claims::AuditContext.set(actor:) do
      claim.submitted!
      claim.draft!
      claim.internal_draft!
    end
    last_audit = claim.audits.order(:id).last
    Claims::ClaimStatusChange.where(claim:).delete_all

    Claims::ClaimStatusChange::Backfill.call(claim_id: claim.id, high_water_mark: last_audit.id - 1)
    result = Claims::ClaimStatusChange::Backfill.call(claim_id: claim.id, after_audit_id: last_audit.id - 1)

    expect(result[:imported_count]).to eq(1)
    expect(claim.status_changes.order(:sequence).last).to have_attributes(from_status: "draft", to_status: "internal_draft")
    expect(Claims::ClaimStatusChange::Reconcile.call(claim_id: claim.id)).to include(ok: true)
  end

  it "recognizes live provenance without equating its actor and occurrence time with Audited" do
    claim = create(:claim, :draft)
    Claims::AuditContext.set(actor:) { claim.submitted! }
    event = claim.status_changes.sole
    audit = Audited::Audit.find(event.legacy_audit_id)
    audit.update_columns(created_at: event.occurred_at - 1.second, user_id: nil, user_type: nil)

    expect {
      Claims::ClaimStatusChange::Backfill.call(claim_id: claim.id)
    }.not_to change(Claims::ClaimStatusChange, :count)
    expect(Claims::ClaimStatusChange::Reconcile.call(claim_id: claim.id)).to include(ok: true)
  end
end
