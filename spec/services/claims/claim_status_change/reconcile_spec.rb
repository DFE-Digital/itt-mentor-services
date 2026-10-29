require "rails_helper"

RSpec.describe Claims::ClaimStatusChange::Reconcile do
  describe ".call" do
    let(:claim) { create(:claim) }

    before do
      create_status_audit("internal_draft", "submitted", created_at: nil)
      create_status_audit("submitted", "payment_in_progress")
      Claims::ClaimStatusChange::Backfill.call(claim_id: claim.id)
    end

    it "passes when every eligible audit maps to one unchanged event and reports retained evidence gaps" do
      result = described_class.call(claim_id: claim.id)

      expect(result).to include(ok: true)
      expect(result[:errors]).to be_empty
      expect(result[:classified_gaps]).to be_an(Array)
    end

    it "raises when an eligible source audit has no mapped event" do
      Claims::ClaimStatusChange.where(claim:).last.then do |event|
        Claims::ClaimStatusChange.where(id: event.id).delete_all
      end

      expect { described_class.call(claim_id: claim.id) }
        .to raise_error(Claims::ClaimStatusChange::Reconcile::Failure, /[Uu]nmapped/)
    end

    it "raises when a mapped event no longer agrees with its preserved source payload" do
      Claims::ClaimStatusChange.where(claim:).update_all(to_status: "paid")

      expect { described_class.call(claim_id: claim.id) }
        .to raise_error(Claims::ClaimStatusChange::Reconcile::Failure, /payload/)
    end

    it "does not mistake a repeated status pair with a different operation for a duplicate" do
      expect(described_class.call(claim_id: claim.id)).to include(ok: true)
    end

    it "raises when preserved source metadata differs from the backfill baseline" do
      baseline = Claims::ClaimStatusChange::Backfill.call(claim_id: claim.id, dry_run: true)[:source_snapshot]
      claim.audits.order(:id).last.update_column(:comment, "unexpectedly changed")

      expect {
        described_class.call(claim_id: claim.id, baseline: { "source_snapshot" => baseline })
      }.to raise_error(Claims::ClaimStatusChange::Reconcile::Failure, /source checksum/)
    end

    it "does not fail solely because historical actor or occurrence time is unknown" do
      result = described_class.call(claim_id: claim.id)

      expect(result).to include(ok: true)
      expect(result[:classified_gaps]).to include(
        include(classification: :unknown_actor, count: 2),
        include(classification: :unknown_occurrence_time, count: 1),
      )
    end

    it "reports a current claim status that is not represented by its latest event" do
      reconciled_claim = create(:claim)
      Audited::Audit.create!(
        auditable: reconciled_claim,
        action: "update",
        version: reconciled_claim.audits.maximum(:version).to_i + 1,
        audited_changes: { "status" => %w[draft submitted] },
        created_at: Time.zone.parse("2026-01-02 12:00:00"),
      )
      reconciled_claim.update_column(:status, "submitted")
      Claims::ClaimStatusChange::Backfill.call(claim_id: reconciled_claim.id)
      reconciled_claim.update_column(:status, "paid")

      result = described_class.call(claim_id: reconciled_claim.id)

      expect(result[:current_state_results][:gaps]).to include(
        include(reason: "current_status_not_represented", latest_event_status: "submitted"),
      )
      expect(result[:classified_gaps]).to include(
        include(classification: :current_status_mismatch, count: 1),
      )
    end

    it "reports a non-draft claim with no canonical event" do
      unrepresented_claim = create(:claim)
      unrepresented_claim.update_column(:status, "submitted")

      result = described_class.call(claim_id: unrepresented_claim.id)

      expect(result[:current_state_results][:gaps]).to include(
        include(reason: "non_draft_status_without_event", current_status: "submitted"),
      )
    end

    context "when source attachments exist" do
      let(:file_data) { "audit evidence bytes" }
      let(:file_checksum) { Base64.strict_encode64(Digest::MD5.digest(file_data)) }
      let(:attachment_id) { SecureRandom.uuid }
      let(:blob_id) { SecureRandom.uuid }
      let(:blob_service) { instance_double(ActiveStorage::Service) }
      let(:blob) do
        instance_double(
          ActiveStorage::Blob,
          id: blob_id,
          key: "opaque-object-key",
          checksum: file_checksum,
          byte_size: file_data.bytesize,
          service: blob_service,
        )
      end
      let(:attachment) { instance_double(ActiveStorage::Attachment, blob:, record: claim) }
      let(:attachment_manifest) do
        {
          record_type: "Claims::Payment",
          record_id: SecureRandom.uuid,
          blob_id:,
          blob_checksum: file_checksum,
          blob_byte_size: file_data.bytesize,
          blob_metadata_checksum: "blob-metadata-fingerprint",
          blob_exists: true,
          attachment_checksum: "attachment-fingerprint",
        }
      end

      before do
        allow(Claims::ClaimStatusChange::LegacyAudit)
          .to receive(:attachment_snapshots)
          .and_return(attachment_id => attachment_manifest)
        allow(ActiveStorage::Attachment)
          .to receive(:find_by)
          .with(id: attachment_id)
          .and_return(attachment)
        allow(blob_service).to receive(:download) do |_key, &block|
          block.call(file_data)
        end
      end

      it "streams and reports the verified attachment checksum" do
        result = described_class.call(claim_id: claim.id)

        expect(result[:attachment_results]).to include(total: 1, verified: 1, missing: 0, invalid_checksum: 0)
        expect(result[:attachment_results][:files].first).to include(
          attachment_id:,
          checksum: file_checksum,
          actual_checksum: file_checksum,
          byte_size: file_data.bytesize,
          actual_byte_size: file_data.bytesize,
          exists: true,
          status: "verified",
        )
      end

      context "when file bytes do not match the stored checksum" do
        let(:file_checksum) { Base64.strict_encode64(Digest::MD5.digest("different bytes")) }

        it "fails reconciliation instead of relying on attachment counts" do
          expect { described_class.call(claim_id: claim.id) }
            .to raise_error(Claims::ClaimStatusChange::Reconcile::Failure, /checksum is corrupt/)
        end
      end

      it "streams response bytes returned directly by the storage service" do
        allow(blob_service).to receive(:download).with("opaque-object-key").and_return(file_data)

        result = described_class.call(claim_id: claim.id)

        expect(result[:attachment_results]).to include(total: 1, verified: 1)
      end

      it "reports a missing file as a historical gap when it was already missing at baseline" do
        manifest = {
          record_type: "Claims::Payment",
          record_id: SecureRandom.uuid,
          blob_id: SecureRandom.uuid,
          blob_checksum: "stored-checksum",
          blob_byte_size: 10,
          blob_metadata_checksum: "blob-metadata-fingerprint",
          blob_exists: false,
          attachment_checksum: "attachment-fingerprint",
        }
        allow(Claims::ClaimStatusChange::LegacyAudit)
          .to receive(:attachment_snapshots)
          .and_return("missing-attachment" => manifest)
        allow(ActiveStorage::Attachment).to receive(:find_by).with(id: "missing-attachment").and_return(nil)

        result = described_class.call(claim_id: claim.id)

        expect(result).to include(ok: true)
        expect(result[:attachment_results]).to include(total: 1, missing: 1)
        expect(result[:classified_gaps]).to include(
          include(classification: :missing_blob_at_baseline, count: 1),
        )
      end
    end

    def create_status_audit(from_status, to_status, created_at: Time.zone.parse("2026-01-01 12:00:00"))
      version = claim.audits.maximum(:version).to_i + 1
      audit = Audited::Audit.create!(
        auditable: claim,
        action: "update",
        version:,
        audited_changes: { "status" => [from_status, to_status] },
        created_at: created_at && created_at + version.seconds,
      )
      audit.update_column(:created_at, nil) if created_at.nil?
      claim.update_column(:status, to_status)
      audit
    end
  end
end
