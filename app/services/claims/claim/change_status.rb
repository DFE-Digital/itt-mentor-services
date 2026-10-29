class Claims::Claim::ChangeStatus < ApplicationService
  class StaleStatus < StandardError; end

  def initialize(claim:, attributes:, actor: Claims::AuditContext.actor, system_operation: Claims::AuditContext.system_operation,
                 source: Claims::AuditContext.source, operation_id: Claims::AuditContext.operation_id, expected_status: nil)
    @claim = claim
    @attributes = attributes
    @actor = actor
    @system_operation = system_operation
    @source = source
    @operation_id = operation_id
    @expected_status = expected_status || (claim.persisted? ? claim.status_in_database : claim.status)
  end

  def call
    claim.with_status_lock do |current_status|
      persist(current_status:)
    end
  end

  private

  attr_reader :claim, :attributes, :actor, :system_operation, :source, :operation_id, :expected_status

  def persist(current_status:)
    if operation_id.present? && (event = claim.status_changes.find_by(operation_id:))
      raise ArgumentError, "Operation already recorded a different status" unless event.to_status == attributes.fetch(:status).to_s

      return true
    end
    if expected_status && current_status != expected_status.to_s
      raise StaleStatus, "Expected #{expected_status}, found #{current_status}"
    end

    Claims::AuditContext.set(actor:, system_operation:, source:, operation_id:) do
      claim.update!(attributes)
    end
  end
end
