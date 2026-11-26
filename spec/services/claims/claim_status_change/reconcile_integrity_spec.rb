require "rails_helper"

RSpec.describe Claims::ClaimStatusChange::Reconcile do
  let(:service) { described_class.send(:new) }
  let(:errors) { [] }
  let(:gaps) { Hash.new(0) }
  let(:legacy) { Claims::ClaimStatusChange::LegacyAudit }

  describe "baseline integrity" do
    it "rejects a baseline without a source snapshot" do
      expect { described_class.call(baseline: {}) }
        .to raise_error(described_class::Failure, /source snapshot/)
    end

    it "normalizes nested report arrays and compares unchanged records" do
      expect(service.send(:normalize_hash, [{ nested: [1] }])).to eq([{ "nested" => [1] }])
      snapshot = { records: { "audit" => { count: 1, checksum: "same" } } }
      service.send(:compare_source_snapshot!, service.send(:normalize_hash, snapshot), snapshot, errors)
      expect(errors).to be_empty
    end

    it "detects removed, added and changed attachment metadata" do
      service.send(
        :compare_source_snapshot!,
        { "attachments" => { "removed" => {}, "changed" => { "checksum" => "original" }, "same" => {} } },
        { "attachments" => { "added" => {}, "changed" => { "checksum" => "changed" }, "same" => {} } },
        errors,
      )

      expect(errors).to include(
        /removed.*missing/,
        /added.*added/,
        /checksum mismatch for changed/,
      )
    end

    it "detects sources changing while reconciliation runs" do
      allow(legacy).to receive(:source_snapshot).and_return({ records: {} }, { records: { changed: {} } })

      expect { described_class.call }
        .to raise_error(described_class::Failure, /changed during reconciliation/)
    end

    it "accepts a bounded baseline with unchanged sources" do
      create(:claim)
      report = Claims::ClaimStatusChange::Backfill.call(dry_run: true)

      expect(described_class.call(baseline: report)).to include(ok: true, baseline_comparison: "matched")
    end
  end

  describe "activity classification" do
    it "distinguishes retained, unlinked, missing and unresolvable records" do
      claim = build_stubbed(:claim)
      records = [
        claim,
        nil,
        double(claims: []),
        double(claims: [claim]),
        double(claim:),
        Object.new,
      ]
      activities = records.map { |record| double(record:) }
      invalid = double
      allow(invalid).to receive(:record).and_raise(NameError)
      allow(Claims::ClaimActivity).to receive(:find_each) do |&block|
        (activities + [invalid]).each(&block)
      end

      expect(service.send(:classify_activities, gaps))
        .to eq(total: 7, orphaned: 2, unlinked: 2)
    end
  end

  describe "batch classification" do
    it "distinguishes linked, unlinked and orphaned batch sources without inferring claims" do
      claim = build_stubbed(:claim)
      records = [
        double(claim: nil),
        double(claim:),
        double(claims: []),
        double(claims: [claim]),
        Object.new,
      ]
      invalid = double
      allow(invalid).to receive(:respond_to?).with(:claim).and_raise(NameError)
      allow(Claims::Payment).to receive(:find_each) do |&block|
        (records + [invalid]).each(&block)
      end

      result = service.send(:classify_batch_sources, gaps)

      expect(result["Claims::Payment"]).to eq(total: 6, orphaned: 2, unlinked: 2)
    end

    it "skips absent historical source models and tables" do
      stub_const("Claims::ClaimStatusChange::LegacyAudit::SOURCE_RECORD_TYPES", ["MissingLegacyModel", "Claims::Payment"])
      allow(Claims::Payment).to receive(:table_exists?).and_return(false)

      expect(service.send(:classify_batch_sources, gaps)).to eq({})
    end
  end

  describe "attachment checks" do
    let(:manifest) do
      { blob_id: "blob", blob_checksum: "checksum", blob_byte_size: 1, blob_exists: true }
    end
    let(:attachment) { double(blob: nil, record: nil) }

    before do
      allow(legacy).to receive(:attachment_snapshots).and_return("attachment" => manifest)
      allow(ActiveStorage::Attachment).to receive(:find_by).with(id: "attachment").and_return(attachment)
    end

    it "fails if a file that existed at baseline is now unavailable" do
      baseline = { "attachments" => { "attachment" => { "blob_exists" => true } } }

      result = service.send(:reconcile_attachments, baseline, errors, gaps)

      expect(result).to include(missing: 1)
      expect(errors).to include(/blob attachment is missing/)
      expect(gaps[:orphaned_attachment]).to eq(1)
    end

    it "classifies an unresolvable attachment owner without hiding a missing blob" do
      allow(attachment).to receive(:record).and_raise(NameError)

      result = service.send(:reconcile_attachments, nil, errors, gaps)

      expect(result).to include(missing: 1)
      expect(gaps[:orphaned_attachment]).to eq(1)
      expect(errors).to be_empty
    end

    it "surfaces unexpected storage failures" do
      allow(attachment).to receive(:blob).and_raise(IOError)

      result = service.send(:reconcile_attachments, nil, errors, gaps)

      expect(result[:files]).to include(attachment_id: "attachment", status: "unclassified_error")
      expect(errors).to include(/Unclassified attachment check failure/)
    end
  end

  describe "canonical provenance checks" do
    def create_audit(claim, changes, action: "update")
      Audited::Audit.create!(
        auditable: claim,
        action:,
        version: claim.audits.maximum(:version).to_i + 1,
        audited_changes: changes,
      )
    end

    def import_event(claim, audit, **attributes)
      Claims::ClaimStatusChange.create!(
        claim:,
        from_status: "draft",
        to_status: "submitted",
        actor_kind: "unknown",
        sequence: Claims::ClaimStatusChange.where(claim:).maximum(:sequence).to_i + 1,
        legacy_audit_id: audit&.id,
        imported: true,
        **attributes,
      )
    end

    it "classifies non-status, destroyed and unchanged audits and rejects malformed audits" do
      claim = create(:claim)
      create_audit(claim, { "name" => %w[old new] })
      create_audit(claim, { "status" => "submitted" }, action: "destroy")
      create_audit(claim, { "status" => %w[submitted submitted] })
      create_audit(claim, { "status" => "submitted" })

      service.send(:reconcile_claim_audits, errors, gaps)

      expect(errors).to include(/Unclassified claim audit/)
      expect(gaps).to include(non_status_audit: 1, destroyed_status_audit: 1, unchanged_status_audit: 1)
    end

    it "does not report a known actor as an unknown historical actor" do
      claim = create(:claim)
      audit = create_audit(claim, { "status" => %w[draft submitted] })
      audit.update_columns(user_id: SecureRandom.uuid, user_type: "Claims::SupportUser", username: "Known actor")
      Claims::ClaimStatusChange::Backfill.call(claim_id: claim.id)

      service.send(:reconcile_claim_audits, errors, gaps)

      expect(errors).to be_empty
      expect(gaps[:unknown_actor]).to eq(0)
    end

    it "surfaces duplicate provenance and sequences if database uniqueness guarantees are lost" do
      audit_relation = Audited::Audit.none
      allow(service).to receive(:claim_audit_scope).and_return(audit_relation)
      provenance = double
      sequences = double
      where_chain = double
      referenced = double
      allow(Claims::ClaimStatusChange).to receive(:where).with(no_args).and_return(where_chain)
      allow(where_chain).to receive(:not).with(legacy_audit_id: nil).and_return(referenced)
      allow(referenced).to receive(:group).with(:legacy_audit_id).and_return(provenance)
      allow(provenance).to receive(:having).with("COUNT(*) > 1").and_return(provenance)
      allow(provenance).to receive(:count).and_return(12 => 2)
      allow(Claims::ClaimStatusChange).to receive(:group).with(:claim_id, :sequence).and_return(sequences)
      allow(sequences).to receive(:having).with("COUNT(*) > 1").and_return(sequences)
      allow(sequences).to receive(:count).and_return(["claim-id", 1] => 2)

      result = service.send(:reconcile_claim_audits, errors, gaps)

      expect(result).to include(duplicate_provenance: 1, duplicate_sequences: 1)
      expect(errors).to include(/Duplicate legacy audit provenance/, /Duplicate claim status sequences/)
    end

    it "rejects a fabricated event for a non-transition audit" do
      claim = create(:claim)
      audit = create_audit(claim, { "name" => %w[old new] })
      import_event(claim, audit)

      service.send(:reconcile_claim_audits, errors, gaps)

      expect(errors).to include(/invented status change/)
    end

    it "classifies an imported transition whose claim was subsequently deleted" do
      claim = create(:claim)
      create_audit(claim, { "status" => %w[draft submitted] })
      Claims::ClaimStatusChange::Backfill.call(claim_id: claim.id)
      claim.delete

      service.send(:reconcile_claim_audits, errors, gaps)

      expect(errors).to be_empty
      expect(gaps[:orphaned_transition]).to eq(1)
    end

    it "rejects a changed imported transition even after claim deletion" do
      claim = create(:claim)
      create_audit(claim, { "status" => %w[draft submitted] })
      Claims::ClaimStatusChange::Backfill.call(claim_id: claim.id)
      Claims::ClaimStatusChange.where(claim:).update_all(to_status: "paid")
      claim.delete

      service.send(:reconcile_claim_audits, errors, gaps)

      expect(errors).to include(/payload mismatch for orphaned/)
    end

    it "rejects missing provenance and missing original source audits" do
      claim = create(:claim)
      import_event(claim, nil)
      audit = create_audit(claim, { "status" => %w[draft submitted] })
      import_event(claim, audit)
      audit.delete

      service.send(:reconcile_imported_events, errors)

      expect(errors).to include(/no audit provenance/, /references missing source audit/)
    end

    it "rejects duplicate transition identities with missing operation IDs" do
      claim = create(:claim)
      import_event(claim, nil)
      import_event(claim, nil)

      service.send(:reconcile_imported_events, errors)

      expect(errors).to include(/Duplicate canonical transitions/)
    end

    it "checks all claims and reports represented and unrepresented current statuses" do
      claim = create(:claim)
      audit = create_audit(claim, { "status" => %w[draft submitted] })
      Claims::ClaimStatusChange::Backfill.call(claim_id: claim.id)
      claim.update_column(:status, "submitted")

      expect(service.send(:reconcile_current_state, gaps)[:gaps]).to be_empty
      expect(audit).to be_persisted
      claim.update_column(:status, "paid")

      expect(service.send(:reconcile_current_state, gaps)[:gaps])
        .to include(include(reason: "current_status_not_represented"))
    end
  end
end
