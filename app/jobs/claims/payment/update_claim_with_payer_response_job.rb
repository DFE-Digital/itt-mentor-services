class Claims::Payment::UpdateClaimWithPayerResponseJob < ApplicationJob
  queue_as :default

  def perform(claim_update_details, notification_wait_time: 0.minutes, response: nil)
    unless %w[paid unpaid].include?(claim_update_details.fetch(:status))
      raise ArgumentError, "Unsupported payer response status"
    end

    record = Claims::Claim.find(claim_update_details.fetch(:id))
    Claims::AuditContext.set(actor: response ? response.user : Claims::AuditContext.actor, source: response,
                             operation_id: response ? "payer-response:#{response.id}" : nil) do
      Claims::AuditContext.validate!
      record.with_lock do
        if Claims::AuditContext.operation_id && (event = record.status_changes.find_by(operation_id: Claims::AuditContext.operation_id))
          destination = claim_update_details.fetch(:status) == "paid" ? "paid" : "payment_information_requested"
          raise ArgumentError, "Response already recorded a different status" unless event.to_status == destination

          next
        end
        raise Claims::Claim::ChangeStatus::StaleStatus, "Claim is no longer awaiting a payer response" unless record.payment_in_progress?

        update_claim(record, claim_update_details, notification_wait_time)
      end
    end
  end

  private

  def update_claim(record, claim_update_details, notification_wait_time)
    if claim_update_details.fetch(:status) == "paid"
      Claims::Claim::Payment::Paid.call(
        claim: record,
        paid_to_la: claim_update_details[:paid_to_la],
        date_paid: claim_update_details[:date_paid],
        notification_wait_time:,
      )
    else
      Claims::Claim::Payment::InformationRequested.call(
        claim: record,
        unpaid_reason: claim_update_details.fetch(:unpaid_reason),
      )
    end
  end
end
