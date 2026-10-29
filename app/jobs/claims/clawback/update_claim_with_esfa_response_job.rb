class Claims::Clawback::UpdateClaimWithESFAResponseJob < ApplicationJob
  queue_as :default

  def perform(claim, response: nil, actor: Claims::AuditContext.actor)
    Claims::AuditContext.set(actor:, source: response, operation_id: response ? "clawback-response:#{response.id}" : nil) do
      Claims::AuditContext.validate!
      claim.with_lock do
        next if Claims::AuditContext.operation_id && claim.status_changes.exists?(operation_id: Claims::AuditContext.operation_id)
        raise Claims::Claim::ChangeStatus::StaleStatus, "Claim is no longer awaiting a clawback response" unless claim.clawback_in_progress?

        Claims::Claim::Clawback::Complete.call(claim:)
      end
    end
  end
end
