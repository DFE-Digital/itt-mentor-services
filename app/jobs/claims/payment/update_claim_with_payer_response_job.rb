class Claims::Payment::UpdateClaimWithPayerResponseJob < ApplicationJob
  queue_as :default

  def perform(claim_update_details, notification_wait_time: 0.minutes)
    if claim_update_details.fetch(:status) == "paid"
      Claims::Claim::Payment::Paid.call(
        claim: claim(claim_update_details.fetch(:id)),
        paid_to_la: claim_update_details[:paid_to_la],
        date_paid: claim_update_details[:date_paid],
        notification_wait_time:,
      )
    elsif claim_update_details.fetch(:status) == "unpaid"
      Claims::Claim::Payment::InformationRequested.call(
        claim: claim(claim_update_details.fetch(:id)),
        unpaid_reason: claim_update_details.fetch(:unpaid_reason),
      )
    end
  end

  private

  def claim(id)
    Claims::Claim.payment_in_progress.find(id)
  end
end
