require "base64"
require "digest"

class Claims::ClaimStatusChange
  class Reconcile < ApplicationService
    class Failure < StandardError; end

    def initialize(claim_id: nil, baseline: nil)
      @claim_id = claim_id
      @baseline = baseline
    end

    def call
      errors = []
      classified_gaps = Hash.new(0)
      baseline_snapshot = snapshot_from_baseline
      high_water_mark = baseline_high_water_mark
      before_snapshot = LegacyAudit.source_snapshot(high_water_mark:)

      compare_source_snapshot!(baseline_snapshot, before_snapshot, errors) if baseline_snapshot
      audit_results = reconcile_claim_audits(errors, classified_gaps)
      audit_archive_results = classify_associated_audits(classified_gaps)
      event_results = reconcile_imported_events(errors)
      activity_results = classify_activities(classified_gaps)
      batch_results = classify_batch_sources(classified_gaps)
      attachment_results = reconcile_attachments(baseline_snapshot, errors, classified_gaps)
      current_state_results = reconcile_current_state(classified_gaps)

      after_snapshot = LegacyAudit.source_snapshot(high_water_mark:)
      errors << "Legacy source checksum changed during reconciliation" unless before_snapshot == after_snapshot

      raise Failure, errors.join("; ") if errors.any?

      {
        ok: true,
        errors: [],
        classified_gaps: classified_gaps.filter_map do |classification, count|
          { classification:, count: } if count.positive?
        end,
        source_snapshot: after_snapshot,
        baseline_comparison: baseline_snapshot ? "matched" : "not_supplied",
        audit_results:,
        audit_archive_results:,
        event_results:,
        activity_results:,
        batch_results:,
        attachment_results:,
        current_state_results:,
      }
    end

    private

    def snapshot_from_baseline
      return unless @baseline

      snapshot = @baseline["source_snapshot"] || @baseline[:source_snapshot]
      raise Failure, "Baseline report does not include a source snapshot" unless snapshot.is_a?(Hash)

      normalize_hash(snapshot)
    end

    def baseline_high_water_mark
      return unless @baseline

      @baseline["high_water_mark"] || @baseline[:high_water_mark]
    end

    def normalize_hash(value)
      case value
      when Hash
        value.each_with_object({}) { |(key, item), result| result[key.to_s] = normalize_hash(item) }
      when Array
        value.map { |item| normalize_hash(item) }
      else
        value
      end
    end

    def compare_source_snapshot!(baseline, current, errors)
      current = normalize_hash(current)
      baseline_records = baseline["records"] || {}
      current_records = current["records"] || {}
      (baseline_records.keys | current_records.keys).each do |type|
        next if baseline_records[type] == current_records[type]

        errors << "Legacy source checksum mismatch for #{type}"
      end

      baseline_attachments = baseline["attachments"] || {}
      current_attachments = current["attachments"] || {}
      (baseline_attachments.keys - current_attachments.keys).each do |id|
        errors << "Legacy attachment #{id} is missing from the source snapshot"
      end
      (current_attachments.keys - baseline_attachments.keys).each do |id|
        errors << "Unexpected legacy attachment #{id} was added after the baseline"
      end

      (baseline_attachments.keys & current_attachments.keys).each do |id|
        next if baseline_attachments[id] == current_attachments[id]

        errors << "Legacy attachment checksum mismatch for #{id}"
      end
    end

    def claim_audit_scope
      scope = Audited::Audit.where(auditable_type: Claims::Claim.name)
      scope = scope.where(auditable_id: @claim_id) if @claim_id
      scope = scope.where("audits.id <= ?", baseline_high_water_mark) if baseline_high_water_mark
      scope
    end

    def reconcile_claim_audits(errors, classified_gaps)
      total = 0
      mapped = 0

      claim_audit_scope.order(:auditable_id, :version, :id).find_each do |audit|
        total += 1
        transition = LegacyAudit.transition_for(audit)
        classification = transition[:classification]

        case classification
        when :status_transition
          claim = Claims::Claim.find_by(id: audit.auditable_id)
          unless claim
            event = Claims::ClaimStatusChange.find_by(legacy_audit_id: audit.id)
            if event
              if LegacyAudit.event_matches_audit?(event, audit, transition)
                mapped += 1
                classified_gaps[:orphaned_transition] += 1
              else
                errors << "Status audit payload mismatch for orphaned claim audit #{audit.id}"
              end
            else
              classified_gaps[:orphaned_status_audit] += 1
            end
            next
          end

          event = Claims::ClaimStatusChange.find_by(legacy_audit_id: audit.id)
          if event.nil?
            errors << "Unmapped eligible status audit #{audit.id}"
            next
          end
          unless LegacyAudit.event_matches_audit?(event, audit, transition, claim)
            errors << "Status audit payload mismatch for audit #{audit.id}"
            next
          end

          mapped += 1
          classified_gaps[:unknown_actor] += 1 if event.actor_kind == "unknown"
          classified_gaps[:unknown_occurrence_time] += 1 if event.occurred_at.nil?
        when :draft_history
          classified_gaps[:draft_history] += 1
          reject_unexpected_event(audit, errors)
        when :non_status_audit
          classified_gaps[:non_status_audit] += 1
          reject_unexpected_event(audit, errors)
        when :destroyed_status_audit
          classified_gaps[:destroyed_status_audit] += 1
          reject_unexpected_event(audit, errors)
        when :unchanged_status_audit
          classified_gaps[:unchanged_status_audit] += 1
          reject_unexpected_event(audit, errors)
        else
          errors << "Unclassified claim audit #{audit.id}"
        end
      end

      duplicates = Claims::ClaimStatusChange.where.not(legacy_audit_id: nil)
        .group(:legacy_audit_id)
        .having("COUNT(*) > 1")
        .count
      errors << "Duplicate legacy audit provenance: #{duplicates.keys.join(", ")}" if duplicates.any?
      duplicate_sequences = Claims::ClaimStatusChange.group(:claim_id, :sequence)
        .having("COUNT(*) > 1")
        .count
      errors << "Duplicate claim status sequences: #{duplicate_sequences.keys.length}" if duplicate_sequences.any?

      {
        source_audits: total,
        mapped_transitions: mapped,
        duplicate_provenance: duplicates.length,
        duplicate_sequences: duplicate_sequences.length,
      }
    end

    def reject_unexpected_event(audit, errors)
      return unless Claims::ClaimStatusChange.exists?(legacy_audit_id: audit.id)

      errors << "Non-transition audit #{audit.id} has an invented status change"
    end

    def classify_associated_audits(classified_gaps)
      mentor_audits = Audited::Audit.where(auditable_type: "Claims::MentorTraining")
      associated_audits = Audited::Audit.where(associated_type: Claims::Claim.name)
      associated_audits = associated_audits.where(associated_id: @claim_id) if @claim_id
      associated_audits = associated_audits.where("audits.id <= ?", baseline_high_water_mark) if baseline_high_water_mark
      orphaned = associated_audits.where(associated_id: nil).count +
        associated_audits.where.not(associated_id: nil)
          .where.not(associated_id: Claims::Claim.select(:id))
          .count
      unlinked = mentor_audits.where(associated_type: nil).count
      other_associations = mentor_audits.where.not(associated_type: [nil, Claims::Claim.name]).count

      classified_gaps[:orphaned_associated_audit] += orphaned
      classified_gaps[:unlinked_associated_audit] += unlinked + other_associations
      {
        claim_audits: claim_audit_scope.count,
        associated_audits: associated_audits.count,
        mentor_training_audits: mentor_audits.count,
        orphaned_associated_audits: orphaned,
        unlinked_mentor_training_audits: unlinked + other_associations,
      }
    end

    def reconcile_imported_events(errors)
      all_imported_events = Claims::ClaimStatusChange.where(imported: true)
      all_imported_events = all_imported_events.where(claim_id: @claim_id) if @claim_id
      missing_provenance = all_imported_events.where(legacy_audit_id: nil).count
      errors << "#{missing_provenance} imported status changes have no audit provenance" if missing_provenance.positive?

      events = all_imported_events
      events = events.where("claim_status_changes.legacy_audit_id <= ?", baseline_high_water_mark) if baseline_high_water_mark
      all_events = Claims::ClaimStatusChange.all
      all_events = all_events.where(claim_id: @claim_id) if @claim_id
      referenced_events = all_events.where.not(legacy_audit_id: nil)
      referenced_source_ids = referenced_events.pluck(:legacy_audit_id)
      source_audits = Audited::Audit.where(
        id: referenced_source_ids,
        auditable_type: Claims::Claim.name,
      ).index_by(&:id)
      referenced_events.find_each do |event|
        audit = source_audits[event.legacy_audit_id]
        unless audit
          errors << "Status change #{event.id} references missing source audit #{event.legacy_audit_id}"
          next
        end

        transition = LegacyAudit.transition_for(audit)
        unless transition[:classification] == :status_transition &&
            LegacyAudit.event_matches_audit?(event, audit, transition)
          errors << "Status change payload mismatch for event #{event.id}"
        end
      end

      duplicate_transitions = all_events
        .group(:claim_id, :from_status, :to_status, :occurred_at, :operation_id)
        .having("COUNT(*) > 1")
        .count
      errors << "Duplicate canonical transitions: #{duplicate_transitions.length}" if duplicate_transitions.any?

      { imported_events: events.count, missing_provenance:, duplicate_transitions: duplicate_transitions.length }
    end

    def classify_activities(classified_gaps)
      total = 0
      unlinked = 0
      orphaned = 0

      Claims::ClaimActivity.find_each do |activity|
        total += 1
        record = activity.record
        if record.nil?
          orphaned += 1
        elsif record.respond_to?(:claims) && record.claims.none?
          unlinked += 1
        elsif !record.is_a?(Claims::Claim) && !record.respond_to?(:claim) && !record.respond_to?(:claims)
          unlinked += 1
        end
      rescue NameError, ActiveRecord::RecordNotFound, ActiveRecord::SubclassNotFound
        orphaned += 1
      end

      classified_gaps[:orphaned_activity] += orphaned
      classified_gaps[:unlinked_activity] += unlinked
      { total:, orphaned:, unlinked: }
    end

    def classify_batch_sources(classified_gaps)
      counts = {}

      LegacyAudit::SOURCE_RECORD_TYPES.reject { |type| type == "Claims::ClaimActivity" }.each do |type|
        model = type.safe_constantize
        next unless model&.table_exists?

        total = 0
        orphaned = 0
        unlinked = 0
        model.find_each do |record|
          total += 1
          if record.respond_to?(:claim) && record.claim.nil?
            orphaned += 1
          elsif record.respond_to?(:claims) && record.claims.none?
            unlinked += 1
          elsif !record.respond_to?(:claim) && !record.respond_to?(:claims)
            unlinked += 1
          end
        rescue NameError, ActiveRecord::RecordNotFound, ActiveRecord::SubclassNotFound
          orphaned += 1
        end

        counts[type] = { total:, orphaned:, unlinked: }
        classified_gaps[:orphaned_batch_source] += orphaned
        classified_gaps[:unlinked_batch_source] += unlinked
      end

      counts
    end

    def reconcile_current_state(classified_gaps)
      gaps = []
      claims_with_events = Claims::ClaimStatusChange.select(:claim_id).distinct
      claims = Claims::Claim.where(id: claims_with_events)
      claims = claims.where(id: @claim_id) if @claim_id

      claims.find_each do |claim|
        events = Claims::ClaimStatusChange.where(claim_id: claim.id)
        if events.where(occurred_at: nil).exists?
          classified_gaps[:current_state_order_unknown] += 1
          gaps << {
            claim_id: claim.id,
            current_status: claim.status,
            reason: "event_occurrence_time_unknown",
          }
          next
        end

        latest_event = events.order(Arel.sql("occurred_at DESC, sequence DESC, id DESC")).first
        next if latest_event.to_status == claim.status

        classified_gaps[:current_status_mismatch] += 1
        gaps << {
          claim_id: claim.id,
          current_status: claim.status,
          latest_event_status: latest_event.to_status,
          reason: "current_status_not_represented",
        }
      end

      draft_statuses = Claims::ClaimStatusChange::LegacyAudit::DRAFT_STATUSES
      claims_without_events = Claims::Claim.where.not(status: draft_statuses)
        .where.not(id: Claims::ClaimStatusChange.select(:claim_id))
      claims_without_events = claims_without_events.where(id: @claim_id) if @claim_id
      claims_without_events.find_each do |claim|
        classified_gaps[:current_status_without_event] += 1
        gaps << {
          claim_id: claim.id,
          current_status: claim.status,
          reason: "non_draft_status_without_event",
        }
      end

      { checked: claims.count, gaps: }
    end

    def reconcile_attachments(baseline, errors, classified_gaps)
      attachment_snapshot = LegacyAudit.attachment_snapshots
      baseline_attachments = baseline&.fetch("attachments", {}) || {}
      verified = 0
      missing = 0
      invalid_checksum = 0
      files = []

      attachment_snapshot.each do |attachment_id, manifest|
        attachment = ActiveStorage::Attachment.find_by(id: attachment_id)
        blob = attachment&.blob
        if attachment
          begin
            classified_gaps[:orphaned_attachment] += 1 if attachment.record.nil?
          rescue NameError, ActiveRecord::RecordNotFound, ActiveRecord::SubclassNotFound
            classified_gaps[:orphaned_attachment] += 1
          end
        end
        unless blob && manifest[:blob_exists]
          missing += 1
          baseline_entry = baseline_attachments[attachment_id]
          if baseline_entry && baseline_entry["blob_exists"]
            errors << "Legacy attachment blob #{attachment_id} is missing"
          else
            classified_gaps[:missing_blob_at_baseline] += 1
          end
          files << {
            attachment_id:,
            blob_id: manifest[:blob_id],
            checksum: manifest[:blob_checksum],
            blob_metadata_checksum: manifest[:blob_metadata_checksum],
            byte_size: manifest[:blob_byte_size],
            attachment_checksum: manifest[:attachment_checksum],
            exists: false,
            status: "missing_blob",
          }
          next
        end

        actual_checksum, actual_byte_size = attachment_integrity(blob)
        unless actual_checksum == blob.checksum && actual_byte_size == blob.byte_size
          invalid_checksum += 1
          errors << "Legacy attachment checksum is corrupt or size differs for #{attachment_id}"
          files << {
            attachment_id:,
            blob_id: blob.id,
            checksum: blob.checksum,
            actual_checksum:,
            blob_metadata_checksum: manifest[:blob_metadata_checksum],
            byte_size: blob.byte_size,
            actual_byte_size:,
            attachment_checksum: manifest[:attachment_checksum],
            exists: true,
            status: "checksum_mismatch",
          }
          next
        end

        verified += 1
        files << {
          attachment_id:,
          blob_id: blob.id,
          checksum: blob.checksum,
          actual_checksum:,
          blob_metadata_checksum: manifest[:blob_metadata_checksum],
          byte_size: blob.byte_size,
          actual_byte_size:,
          attachment_checksum: manifest[:attachment_checksum],
          exists: true,
          status: "verified",
        }
      rescue StandardError => e
        errors << "Unclassified attachment check failure for #{attachment_id}: #{e.class}"
        files << { attachment_id:, status: "unclassified_error" }
      end

      {
        total: attachment_snapshot.length,
        verified:,
        missing:,
        invalid_checksum:,
        files:,
      }
    end

    def attachment_integrity(blob)
      digest = Digest::MD5.new
      byte_size = 0
      response = blob.service.download(blob.key) do |chunk|
        digest << chunk
        byte_size += chunk.bytesize
      end
      if response.is_a?(String)
        digest << response
        byte_size += response.bytesize
      end

      [Base64.strict_encode64(digest.digest), byte_size]
    end
  end
end
