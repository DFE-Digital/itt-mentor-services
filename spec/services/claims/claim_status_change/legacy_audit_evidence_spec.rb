require "rails_helper"

RSpec.describe Claims::ClaimStatusChange::LegacyAudit do
  describe ".record_snapshots" do
    it "fingerprints every source record, including otherwise unlinked activities" do
      activity = create(:claim_activity, action: :approved_by_school, record: create(:claim))

      snapshot = described_class.record_snapshots

      expect(snapshot["Claims::ClaimActivity"]).to include(count: 1)
      activity.update_column(:action, "submitted")
      expect(described_class.record_snapshots["Claims::ClaimActivity"][:checksum])
        .not_to eq(snapshot["Claims::ClaimActivity"][:checksum])
    end

    it "skips absent historical source models and tables" do
      stub_const("Claims::ClaimStatusChange::LegacyAudit::SOURCE_RECORD_TYPES", ["MissingLegacyModel", "Claims::Payment"])
      allow(Claims::Payment).to receive(:table_exists?).and_return(false)

      expect(described_class.record_snapshots).to eq({})
    end
  end

  describe ".attachment_snapshots" do
    it "captures attachment and blob fingerprints and tests actual file existence" do
      attachment = ActiveStorage::Attachment.new(
        id: SecureRandom.uuid, name: "csv_file", record_type: "Claims::Payment", record_id: SecureRandom.uuid,
      )
      blob = ActiveStorage::Blob.new(
        id: SecureRandom.uuid, key: "historical-file", filename: "evidence.csv", checksum: "stored-checksum",
        byte_size: 12, service_name: "test"
      )
      attachment.blob = blob
      storage = instance_double(ActiveStorage::Service)
      allow(blob).to receive(:service).and_return(storage)
      allow(storage).to receive(:exist?).with("historical-file").and_return(true)
      relation = double
      allow(ActiveStorage::Attachment).to receive(:includes).with(:blob).and_return(relation)
      allow(relation).to receive(:where).with(record_type: described_class::ATTACHMENT_RECORD_TYPES).and_return(relation)
      allow(relation).to receive(:find_each).and_return([attachment].each)

      expect(described_class.attachment_snapshots[attachment.id]).to include(
        blob_exists: true,
        blob_checksum: "stored-checksum",
        blob_byte_size: 12,
        blob_metadata_checksum: described_class.checksum(blob),
        attachment_checksum: described_class.checksum(attachment),
      )
      allow(storage).to receive(:exist?).and_return(false)
      expect(described_class.attachment_snapshots[attachment.id]).to include(blob_exists: false)
      allow(blob).to receive(:service).and_return(nil)
      expect(described_class.attachment_snapshots[attachment.id]).to include(blob_exists: false)
      allow(attachment).to receive(:blob).and_return(nil)
      expect(described_class.attachment_snapshots[attachment.id]).to include(
        blob_exists: false, blob_checksum: nil, blob_byte_size: nil, blob_metadata_checksum: nil,
      )
    end

    it "returns an empty inventory if attachment storage has not been installed" do
      allow(ActiveStorage::Attachment).to receive(:table_exists?).and_return(false)

      expect(described_class.attachment_snapshots).to eq({})
    end
  end

  describe ".event_matches_audit?" do
    it "rejects imported events without preservation checksum details" do
      claim = create(:claim)
      audit = Audited::Audit.create!(
        auditable: claim, action: "update", version: claim.audits.maximum(:version).to_i + 1,
        audited_changes: { "status" => %w[draft submitted] }
      )
      Claims::ClaimStatusChange::Backfill.call(claim_id: claim.id)
      event = Claims::ClaimStatusChange.find_by!(legacy_audit_id: audit.id)
      allow(event).to receive(:details).and_return(nil)

      expect(described_class.event_matches_audit?(event, audit, described_class.transition_for(audit))).to be(false)
    end
  end
end
