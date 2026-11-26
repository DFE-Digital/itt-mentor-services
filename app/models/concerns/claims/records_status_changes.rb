module Claims::RecordsStatusChanges
  extend ActiveSupport::Concern

  included do
    has_many :status_changes, class_name: "Claims::ClaimStatusChange", foreign_key: :claim_id

    before_save :prepare_status_change
    after_save :record_status_change
  end

  def with_status_lock
    self.class.transaction do
      locked_claim = Claims::AuditContext.locked_claim
      if locked_claim&.id == id && persisted?
        yield locked_claim.status
      else
        locked_claim = persisted? ? self.class.select(:id, :status).lock.find(id) : self
        Claims::AuditContext.set(locked_claim:) { yield locked_claim.status }
      end
    end
  end

  private

  def prepare_status_change
    @record_status_change = false
    return unless will_save_change_to_status?

    if persisted?
      locked_claim = Claims::AuditContext.locked_claim
      persisted_status = if locked_claim&.id == id
                           locked_claim.status
                         else
                           self.class.where(id:).lock.pick(:status)
                         end
      if persisted_status != status_in_database
        raise ActiveRecord::StaleObjectError.new(self, "change status")
      end
    end
    @record_status_change = audited_lifecycle_change?
    return unless @record_status_change

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

    context = Claims::AuditContext
    context.locked_claim.status = status if context.locked_claim&.id == id
    return unless @record_status_change

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
