require "rails_helper"

RSpec.describe Claims::ClaimStatusChange::LegacyAudit do
  describe ".transition_for" do
    def audit(changes:, action: "update")
      instance_double(Audited::Audit, audited_changes: changes, action:)
    end

    it "accepts a legacy create with a scalar status" do
      expect(described_class.transition_for(audit(changes: { "status" => "submitted" }, action: "create")))
        .to include(classification: :status_transition, from_status: nil, to_status: "submitted")
    end

    it "accepts a legacy create with a one-value status array" do
      expect(described_class.transition_for(audit(changes: { "status" => %w[submitted] }, action: "create")))
        .to include(classification: :status_transition, from_status: nil, to_status: "submitted")
    end

    it "accepts symbol-keyed status changes and stringifies status values" do
      expect(described_class.transition_for(audit(changes: { status: %i[submitted paid] })))
        .to include(classification: :status_transition, from_status: "submitted", to_status: "paid")
    end

    it "classifies absent, non-hash, destroyed, malformed and empty status changes" do
      expect(described_class.transition_for(audit(changes: nil))).to include(classification: :unclassified_status_audit)
      expect(described_class.transition_for(audit(changes: { "name" => %w[a b] }))).to include(classification: :non_status_audit)
      expect(described_class.transition_for(audit(changes: { "status" => %w[a b] }, action: "destroy")))
        .to include(classification: :destroyed_status_audit)
      expect(described_class.transition_for(audit(changes: { "status" => %w[a] })))
        .to include(classification: :unclassified_status_audit)
      expect(described_class.transition_for(audit(changes: { "status" => [nil, nil] })))
        .to include(classification: :unclassified_status_audit)
    end

    it "classifies deserialization errors as unclassified" do
      malformed_audit = instance_double(Audited::Audit, action: "update")
      allow(malformed_audit).to receive(:audited_changes)
        .and_raise(Psych::SyntaxError.new(nil, 1, 1, 0, "bad YAML", nil))

      expect(described_class.transition_for(malformed_audit))
        .to include(classification: :unclassified_status_audit)
    end

    it "classifies unchanged and draft-only status history without importing it" do
      expect(described_class.transition_for(audit(changes: { "status" => %w[submitted submitted] })))
        .to include(classification: :unchanged_status_audit)
      expect(described_class.transition_for(audit(changes: { "status" => %w[internal_draft draft] })))
        .to include(classification: :draft_history)
      expect(described_class.transition_for(audit(changes: { "status" => %w[draft submitted] })))
        .to include(classification: :status_transition)
      expect(described_class.transition_for(audit(changes: { "status" => %w[submitted draft] })))
        .to include(classification: :status_transition)
    end
  end

  describe ".canonical_value" do
    it "normalizes supported scalar, collection, date and numeric values" do
      value = {
        "time" => Time.zone.parse("2026-01-02 03:04:05"),
        "datetime" => Time.parse("2026-01-02T03:04:05+00:00"),
        "date" => Date.new(2026, 1, 2),
        "decimal" => BigDecimal("1.25"),
        "array" => [true, false, nil, 1],
        :symbol_key => "value",
        "object" => Object.new,
      }

      normalized = described_class.canonical_value(value)

      expect(normalized).to include(
        "time" => value["time"].iso8601(6),
        "datetime" => value["datetime"].iso8601(6),
        "date" => "2026-01-02",
        "decimal" => "1.25",
        "array" => [true, false, nil, 1],
        "symbol_key" => "value",
        "object" => value["object"].to_s,
      )
    end
  end

  describe ".event_matches_audit?" do
    it "checks imported provenance and payload while allowing live events" do
      audit = instance_double(
        Audited::Audit,
        auditable_id: "claim-id",
        created_at: nil,
        user_id: nil,
        user_type: nil,
        username: nil,
        id: 12,
        audited_changes: { "status" => %w[submitted paid] },
      )
      transition = { from_status: "submitted", to_status: "paid", classification: :status_transition }
      event = instance_double(
        Claims::ClaimStatusChange,
        claim_id: "claim-id",
        from_status: "submitted",
        to_status: "paid",
        occurred_at: nil,
        actor_id: nil,
        actor_type: nil,
        legacy_audit_id: 12,
        imported?: false,
      )

      expect(described_class.event_matches_audit?(event, audit, transition)).to be(true)
      expect(described_class.event_matches_audit?(event, audit, transition.merge(to_status: "rejected"))).to be(false)
    end

    it "verifies imported event attribution and source checksum" do
      audit = create(:claim).audits.first
      transition = { from_status: nil, to_status: "submitted", classification: :status_transition }
      event = instance_double(
        Claims::ClaimStatusChange,
        claim_id: audit.auditable_id,
        from_status: nil,
        to_status: "submitted",
        occurred_at: audit.created_at,
        actor_id: audit.user_id,
        actor_type: audit.user_type,
        actor_name: audit.username,
        actor_kind: "unknown",
        operation_id: "legacy-audit-#{audit.id}",
        source_id: nil,
        source_type: nil,
        legacy_audit_id: audit.id,
        imported?: true,
        details: { "legacy_audit_checksum" => described_class.audit_checksum(audit) },
      )

      expect(described_class.event_matches_audit?(event, audit, transition)).to be(true)
      allow(event).to receive(:actor_kind).and_return("user")
      expect(described_class.event_matches_audit?(event, audit, transition)).to be(false)
    end
  end
end
