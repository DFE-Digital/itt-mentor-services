class Claims::ClaimStatusChange
  class Backfill < ApplicationService
    class UnclassifiedAuditError < StandardError; end

    def initialize(claim_id: nil, dry_run: false, limit: 500, after_audit_id: nil, high_water_mark: nil)
      @claim_id = claim_id
      @dry_run = dry_run
      @limit = limit
      @after_audit_id = after_audit_id
      @high_water_mark = high_water_mark
    end

    def call
      validate_options!
      scope = audit_scope
      high_water_mark = @high_water_mark || scope.maximum(:id)
      source_snapshot = LegacyAudit.source_snapshot(high_water_mark:) if @dry_run
      audits = page(scope, high_water_mark)
      classifications = Hash.new(0)
      imported_count = 0
      already_present_count = 0
      sequence_by_claim = {}
      unclassified_audits = []
      unknown_actor_count = 0
      unknown_occurrence_time_count = 0

      audits.each do |audit|
        transition = LegacyAudit.transition_for(audit)
        classifications[transition[:classification]] += 1
        if transition[:classification] == :unclassified_status_audit
          unclassified_audits << audit.id
          next
        end
        next unless transition[:classification] == :status_transition

        claim = Claims::Claim.find_by(id: audit.auditable_id)
        unless claim
          existing = Claims::ClaimStatusChange.find_by(legacy_audit_id: audit.id)
          if existing
            unless LegacyAudit.event_matches_audit?(existing, audit, transition)
              unclassified_audits << audit.id
            end
            already_present_count += 1
          end
          classifications[:orphaned_status_audit] += 1
          next
        end

        unknown_actor_count += 1 if audit.user_id.blank? || audit.user_type.blank?
        unknown_occurrence_time_count += 1 if audit.created_at.nil?
        existing = Claims::ClaimStatusChange.find_by(legacy_audit_id: audit.id)
        if existing
          unless LegacyAudit.event_matches_audit?(existing, audit, transition, claim)
            unclassified_audits << audit.id
          end
          already_present_count += 1
          next
        end

        next_sequence = sequence_by_claim.fetch(claim.id) do
          Claims::ClaimStatusChange.where(claim_id: claim.id).maximum(:sequence).to_i
        end
        sequence_by_claim[claim.id] = next_sequence + 1

        if @dry_run
          imported_count += 1
        else
          imported = import_audit!(claim, audit, transition, sequence_by_claim[claim.id])
          if imported == :orphaned
            classifications[:orphaned_status_audit] += 1
          elsif imported
            imported_count += 1
          else
            already_present_count += 1
          end
        end
      end

      raise UnclassifiedAuditError, "Unclassified or mismatched claim status audits: #{unclassified_audits.join(", ")}" if unclassified_audits.any?

      last_audit_id = audits.last&.id || @after_audit_id || high_water_mark
      {
        dry_run: @dry_run,
        imported_count:,
        already_present_count:,
        classifications: classifications.transform_keys(&:to_s),
        classified_gaps: {
          "draft_history" => classifications[:draft_history],
          "orphaned_status_audit" => classifications[:orphaned_status_audit],
          "unknown_actor" => unknown_actor_count,
          "unknown_occurrence_time" => unknown_occurrence_time_count,
        },
        last_audit_id:,
        high_water_mark:,
        source_snapshot:,
      }
    end

    private

    def validate_options!
      raise ArgumentError, "limit must be a positive integer" if @limit && (!@limit.to_i.positive? || @limit.to_i != @limit)
      raise ArgumentError, "after_audit_id must be non-negative" if @after_audit_id && @after_audit_id.to_i.negative?
      raise ArgumentError, "high_water_mark must be non-negative" if @high_water_mark && @high_water_mark.to_i.negative?
    end

    def audit_scope
      scope = Audited::Audit.where(auditable_type: Claims::Claim.name)
      scope = scope.where(auditable_id: @claim_id) if @claim_id
      scope = scope.where("audits.id > ?", @after_audit_id) if @after_audit_id
      scope = scope.where("audits.id <= ?", @high_water_mark) if @high_water_mark
      scope
    end

    def page(scope, high_water_mark)
      scope = scope.where("audits.id <= ?", high_water_mark) if high_water_mark
      scope.order(:id).limit(@limit)
    end

    def import_audit!(claim, audit, transition, sequence)
      imported = false

      claim.with_lock do
        existing = Claims::ClaimStatusChange.find_by(legacy_audit_id: audit.id)
        if existing
          raise UnclassifiedAuditError, "Audit #{audit.id} is linked to a mismatched status change" unless LegacyAudit.event_matches_audit?(existing, audit, transition, claim)
        else
          sequence = Claims::ClaimStatusChange.where(claim_id: claim.id).maximum(:sequence).to_i + 1
          Claims::ClaimStatusChange.create!(
            claim:,
            from_status: transition[:from_status],
            to_status: transition[:to_status],
            occurred_at: audit.created_at,
            actor_id: audit.user_id,
            actor_type: audit.user_type,
            actor_name: audit.username,
            actor_kind: audit.user_id.present? && audit.user_type.present? ? "user" : "unknown",
            operation_id: "legacy-audit-#{audit.id}",
            sequence:,
            legacy_audit_id: audit.id,
            details: { "legacy_audit_checksum" => LegacyAudit.audit_checksum(audit) },
            imported: true,
          )
          imported = true
        end
      end

      imported
    rescue ActiveRecord::RecordNotUnique
      existing = Claims::ClaimStatusChange.find_by!(legacy_audit_id: audit.id)
      raise UnclassifiedAuditError, "Audit #{audit.id} is linked to a mismatched status change" unless LegacyAudit.event_matches_audit?(existing, audit, transition, claim)

      false
    rescue ActiveRecord::RecordNotFound
      return :orphaned unless Claims::Claim.exists?(id: audit.auditable_id)

      raise
    end
  end
end
