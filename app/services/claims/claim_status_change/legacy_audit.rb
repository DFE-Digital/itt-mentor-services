require "digest"
require "json"

class Claims::ClaimStatusChange
  module LegacyAudit
    DRAFT_STATUSES = %w[draft internal_draft].freeze
    SOURCE_RECORD_TYPES = %w[
      Claims::ClaimActivity
      Claims::Payment
      Claims::PaymentClaim
      Claims::PaymentResponse
      Claims::Sampling
      Claims::ProviderSampling
      Claims::ProviderSamplingClaim
      Claims::Clawback
      Claims::ClawbackClaim
    ].freeze
    ATTACHMENT_RECORD_TYPES = %w[
      Claims::Payment
      Claims::PaymentResponse
      Claims::ProviderSampling
      Claims::Clawback
    ].freeze

    module_function

    def transition_for(audit)
      changes = audit.audited_changes
      return { classification: :unclassified_status_audit } unless changes.is_a?(Hash)

      status_key = changes.key?("status") ? "status" : :status
      return { classification: :non_status_audit } unless changes.key?(status_key)
      return { classification: :destroyed_status_audit } if audit.action == "destroy"

      values = changes[status_key]
      from_status, to_status =
        if values.is_a?(Array) && values.length >= 2
          [values.first, values.last]
        elsif audit.action == "create" && values.is_a?(Array) && values.one?
          [nil, values.first]
        elsif audit.action == "create" && !values.is_a?(Array)
          [nil, values]
        else
          return { classification: :unclassified_status_audit }
        end

      from_status = from_status&.to_s
      to_status = to_status&.to_s
      return { classification: :unclassified_status_audit } if to_status.blank?
      return { classification: :unchanged_status_audit } if from_status == to_status
      return { classification: :draft_history } if draft_history?(from_status, to_status)

      { classification: :status_transition, from_status:, to_status: }
    rescue ArgumentError, TypeError, Psych::Exception
      { classification: :unclassified_status_audit }
    end

    def draft_history?(from_status, to_status)
      DRAFT_STATUSES.include?(to_status) &&
        (from_status.nil? || DRAFT_STATUSES.include?(from_status))
    end

    def checksum(record)
      attributes = record.attributes
      if record.is_a?(Audited::Audit)
        attributes["audited_changes"] = record.read_attribute_before_type_cast("audited_changes")
      end

      Digest::SHA256.hexdigest(JSON.generate(canonical_value(attributes)))
    end

    def audit_checksum(audit)
      checksum(audit)
    end

    def source_snapshot(high_water_mark: nil)
      {
        records: record_snapshots(high_water_mark:),
        attachments: attachment_snapshots,
      }
    end

    def record_snapshots(high_water_mark: nil)
      result = {}

      audit_scope = audit_source_scope
      audit_scope = audit_scope.where("audits.id <= ?", high_water_mark) if high_water_mark
      audit_scope.find_each do |audit|
        add_to_snapshot(result, audit.class.name, audit)
      end
      SOURCE_RECORD_TYPES.each do |type|
        model = type.safe_constantize
        next unless model&.table_exists?

        model.find_each do |record|
          add_to_snapshot(result, type, record)
        end
      end

      result.transform_values do |entries|
        {
          count: entries.length,
          checksum: Digest::SHA256.hexdigest(entries.sort_by(&:first).flatten.join("\n")),
        }
      end
    end

    def attachment_snapshots
      return {} unless defined?(ActiveStorage::Attachment) && ActiveStorage::Attachment.table_exists?

      ActiveStorage::Attachment.includes(:blob).where(record_type: ATTACHMENT_RECORD_TYPES).find_each.each_with_object({}) do |attachment, result|
        blob = attachment.blob
        result[attachment.id.to_s] = {
          record_type: attachment.record_type,
          record_id: attachment.record_id,
          blob_id: attachment.blob_id,
          blob_checksum: blob&.checksum,
          blob_byte_size: blob&.byte_size,
          blob_metadata_checksum: blob && checksum(blob),
          blob_exists: blob&.service&.exist?(blob.key) || false,
          attachment_checksum: checksum(attachment),
        }
      end
    end

    def audit_source_scope
      Audited::Audit.where(auditable_type: %w[Claims::Claim Claims::MentorTraining])
        .or(Audited::Audit.where(associated_type: "Claims::Claim"))
    end

    def canonical_value(value)
      case value
      when Hash
        value.keys.map(&:to_s).sort.index_with do |key|
          original_key = value.key?(key) ? key : key.to_sym
          canonical_value(value[original_key])
        end
      when Array
        value.map { |item| canonical_value(item) }
      when Time, DateTime, ActiveSupport::TimeWithZone
        value.iso8601(6)
      when Date
        value.iso8601
      when BigDecimal
        value.to_s("F")
      when nil, String, Numeric, TrueClass, FalseClass
        value
      else
        value.to_s
      end
    end

    def add_to_snapshot(result, type, record)
      result[type] ||= []
      result[type] << [record.id.to_s, checksum(record)]
    end

    def event_matches_audit?(event, audit, transition, claim = nil)
      event.claim_id == (claim&.id || audit.auditable_id) &&
        event.from_status == transition[:from_status] &&
        event.to_status == transition[:to_status] &&
        event.occurred_at == audit.created_at &&
        event.actor_id == audit.user_id &&
        event.actor_type == audit.user_type &&
        event.legacy_audit_id == audit.id &&
        (
          !event.imported? ||
          (
            event.actor_name == audit.username &&
            event.actor_kind == (audit.user_id.present? && audit.user_type.present? ? "user" : "unknown") &&
            event.operation_id == "legacy-audit-#{audit.id}" &&
            event.source_id.nil? &&
            event.source_type.nil? &&
            event.details&.fetch("legacy_audit_checksum", nil) == audit_checksum(audit)
          )
        )
    end

    private_class_method :add_to_snapshot
  end
end
