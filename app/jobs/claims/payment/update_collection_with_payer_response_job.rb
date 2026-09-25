class Claims::Payment::UpdateCollectionWithPayerResponseJob < ApplicationJob
  queue_as :default

  def perform(claim_update_details)
    notification_schedule = NotifyRateLimiter::Schedule.new

    payment_in_progress_claims(claim_update_details.pluck(:id)).find_in_batches do |batch|
      batch.each do |claim|
        updated_details_for_claim = claim_update_details.find { |details| details[:id] == claim.id }
        next unless %w[paid unpaid].include?(updated_details_for_claim.fetch(:status))

        notification_wait_time = if updated_details_for_claim.fetch(:status) == "paid"
                                   notification_schedule.reserve(claim.school_users.count)
                                 else
                                   0.minutes
                                 end

        Claims::Payment::UpdateClaimWithPayerResponseJob.perform_later(updated_details_for_claim, notification_wait_time:)
      end
    end
  end

  private

  def payment_in_progress_claims(ids)
    Claims::Claim.payment_in_progress.where(id: ids)
  end
end
