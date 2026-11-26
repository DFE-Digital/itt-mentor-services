require "rails_helper"

RSpec.describe Claims::ClaimStatusChange::Backfill do
  describe ".call" do
    let(:claim) { create(:claim) }

    before do
      create_status_audit("internal_draft", "draft")
      create_status_audit("draft", "submitted")
      create_status_audit("submitted", "payment_in_progress")
      create_status_audit("payment_in_progress", "draft")
      create_status_audit("draft", "payment_in_progress")
    end

    it "imports only explicit status audits from the first submission onward" do
      expect { described_class.call(claim_id: claim.id) }
        .to change { Claims::ClaimStatusChange.where(claim:).count }.by(4)

      expect(
        Claims::ClaimStatusChange.where(claim:).order(:sequence).pluck(:from_status, :to_status),
      ).to eq(
        [
          %w[draft submitted],
          %w[submitted payment_in_progress],
          %w[payment_in_progress draft],
          %w[draft payment_in_progress],
        ],
      )
    end

    it "does not mutate original audit payloads or metadata" do
      original_audits = claim.audits.order(:id).map { |audit| audit.attributes.deep_dup }

      described_class.call(claim_id: claim.id)

      expect(claim.audits.order(:id).map(&:attributes)).to eq(original_audits)
    end

    it "does not mutate legacy activities or invent transitions from them" do
      activity = create(:claim_activity, action: :approved_by_school, record: claim)
      original_attributes = activity.attributes.deep_dup

      described_class.call(claim_id: claim.id)

      expect(activity.reload.attributes).to eq(original_attributes)
      expect(Claims::ClaimStatusChange.where(claim:, legacy_audit_id: nil)).to be_empty
    end

    it "is idempotent when rerun" do
      described_class.call(claim_id: claim.id)

      expect { described_class.call(claim_id: claim.id) }
        .not_to(change { Claims::ClaimStatusChange.where(claim:).count })
    end

    it "supports dry runs without writing events" do
      result = described_class.call(claim_id: claim.id, dry_run: true)

      expect(Claims::ClaimStatusChange.where(claim:)).to be_empty
      expect(result).to include(dry_run: true, imported_count: 4)
    end

    it "uses Audited's deserializer for legacy YAML payloads without rewriting them" do
      audit = claim.audits.order(:id).last
      serialized_payload = { "status" => %w[draft payment_in_progress] }.to_yaml
      connection = ActiveRecord::Base.connection
      connection.execute(
        "UPDATE audits SET audited_changes = #{connection.quote(serialized_payload)} WHERE id = #{connection.quote(audit.id)}",
      )

      described_class.call(claim_id: claim.id)

      expect(audit.reload.read_attribute_before_type_cast(:audited_changes)).to eq(serialized_payload)
      expect(Claims::ClaimStatusChange.find_by(legacy_audit_id: audit.id))
        .to have_attributes(from_status: "draft", to_status: "payment_in_progress")
    end

    it "imports an explicit create audit without inventing its predecessor" do
      submitted_claim = create(:claim)
      audit = Audited::Audit.create!(
        auditable: submitted_claim,
        action: "create",
        version: submitted_claim.audits.maximum(:version).to_i + 1,
        audited_changes: { "status" => %w[submitted] },
        created_at: Time.zone.parse("2026-01-01 12:00:00"),
      )
      submitted_claim.update_column(:status, "submitted")

      described_class.call(claim_id: submitted_claim.id)

      expect(Claims::ClaimStatusChange.find_by(legacy_audit_id: audit.id))
        .to have_attributes(from_status: nil, to_status: "submitted")
    end

    it "supports bounded resumable pages and exposes the audit high-water mark" do
      first_page = described_class.call(claim_id: claim.id, limit: 4)

      expect(first_page).to include(imported_count: 2)
      expect(first_page[:high_water_mark]).to be_present

      second_page = described_class.call(
        claim_id: claim.id,
        limit: 4,
        after_audit_id: first_page[:last_audit_id],
        high_water_mark: first_page[:high_water_mark],
      )

      expect(second_page).to include(imported_count: 2)
      expect(Claims::ClaimStatusChange.where(claim:).count).to eq(4)
    end

    it "classifies status audits for a deleted claim without inventing a replacement event" do
      claim_id = claim.id
      claim.delete

      result = described_class.call(claim_id:)

      expect(result[:imported_count]).to eq(0)
      expect(result[:classified_gaps]["orphaned_status_audit"]).to eq(4)
      expect(Claims::ClaimStatusChange.where(claim_id:)).to be_empty
      expect(Claims::ClaimStatusChange::Reconcile.call(claim_id:)).to include(ok: true)
    end

    it "recognizes an already-imported event after its claim has been deleted" do
      claim_id = claim.id
      described_class.call(claim_id:)
      claim.delete

      result = described_class.call(claim_id:)

      expect(result).to include(imported_count: 0, already_present_count: 4)
      expect(result[:classified_gaps]["orphaned_status_audit"]).to eq(4)
    end

    it "rejects malformed status audits instead of guessing a transition" do
      Audited::Audit.create!(
        auditable: claim,
        action: "update",
        version: claim.audits.maximum(:version).to_i + 1,
        audited_changes: { "status" => "submitted" },
      )

      expect { described_class.call(claim_id: claim.id) }
        .to raise_error(Claims::ClaimStatusChange::Backfill::UnclassifiedAuditError, /Unclassified/)
    end

    it "rejects an existing event whose provenance payload does not match" do
      described_class.call(claim_id: claim.id)
      Claims::ClaimStatusChange.where(claim:).limit(1).update_all(to_status: "paid")

      expect { described_class.call(claim_id: claim.id) }
        .to raise_error(Claims::ClaimStatusChange::Backfill::UnclassifiedAuditError, /mismatched/)
    end

    it "validates pagination options before reading source audits" do
      expect { described_class.call(limit: 0) }.to raise_error(ArgumentError, /limit/)
      expect { described_class.call(after_audit_id: -1) }.to raise_error(ArgumentError, /after_audit_id/)
      expect { described_class.call(high_water_mark: -1) }.to raise_error(ArgumentError, /high_water_mark/)
    end

    def create_status_audit(from_status, to_status)
      version = claim.audits.maximum(:version).to_i + 1
      audit = Audited::Audit.create!(
        auditable: claim,
        action: "update",
        version:,
        audited_changes: { "status" => [from_status, to_status] },
        created_at: Time.zone.parse("2026-01-01 12:00:00") + version.seconds,
      )
      claim.update_column(:status, to_status)
      audit
    end
  end
end
