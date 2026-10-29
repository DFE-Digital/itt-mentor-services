module Claims::RecordsStatusChanges
  extend ActiveSupport::Concern

  included do
    has_many :status_changes, class_name: "Claims::ClaimStatusChange", foreign_key: :claim_id

    before_save :prepare_status_change
    after_save :record_status_change
  end

  private

  def prepare_status_change
    return unless will_save_change_to_status?

    if persisted?
      persisted_status = self.class.lock.find(id).status
      if persisted_status != status_in_database
        raise ActiveRecord::StaleObjectError.new(self, "change status")
      end
    end
    return unless audited_lifecycle_change?

    Claims::AuditContext.validate!
  end

  def audited_lifecycle_change?
    previous_status = status_in_database
    !status.in?(self.class::DRAFT_STATUSES.map(&:to_s)) ||
      (previous_status.present? && !previous_status.in?(self.class::DRAFT_STATUSES.map(&:to_s))) ||
      lifecycle_started?
  end

  def record_status_change
    return unless saved_change_to_status?
    return if status.in?(self.class::DRAFT_STATUSES.map(&:to_s)) &&
      (status_before_last_save.nil? || status_before_last_save.in?(self.class::DRAFT_STATUSES.map(&:to_s))) &&
      !lifecycle_started?

    context = Claims::AuditContext
    context.validate!
    actor = context.actor
    audit = audits.reorder(version: :desc).first if auditing_enabled

    Claims::ClaimStatusChange.create!(
      claim: self,
      from_status: status_before_last_save,
      to_status: status,
      occurred_at: Time.current,
      actor:,
      actor_name: actor&.full_name,
      actor_kind: actor ? "user" : "system",
      system_operation: actor ? nil : context.system_operation,
      source: context.source,
      operation_id: context.operation_id,
      sequence: (status_changes.maximum(:sequence) || 0) + 1,
      legacy_audit_id: audit&.id,
      details: saved_changes.slice("sampling_reason", "unpaid_reason", "clawback_requested_by_id", "clawback_approved_by_id"),
    )
  end

  def lifecycle_started?
    return true if status_changes.exists?

    audits.where(action: %w[create update]).any? do |audit|
      Array(audit.audited_changes["status"]).compact.any? do |value|
        !value.in?(self.class::DRAFT_STATUSES.map(&:to_s))
      end
    end
  end
end
