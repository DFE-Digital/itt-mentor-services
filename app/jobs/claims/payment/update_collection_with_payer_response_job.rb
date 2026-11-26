class Claims::Payment::UpdateCollectionWithPayerResponseJob < ApplicationJob
  queue_as :default

  def perform(claim_update_details, response: nil)
    notification_schedule = NotifyRateLimiter::Schedule.new
    details_by_claim = claim_update_details.each_with_object({}) do |details, indexed|
      indexed[details.fetch(:id)] ||= details
    end

    payment_in_progress_claims(details_by_claim.keys).find_in_batches do |batch|
      batch.each do |claim|
        updated_details_for_claim = details_by_claim.fetch(claim.id)
        next unless %w[paid unpaid].include?(updated_details_for_claim.fetch(:status))

        notification_wait_time = if updated_details_for_claim.fetch(:status) == "paid"
                                   notification_schedule.reserve(claim.school_users.count)
                                 else
                                   0.minutes
                                 end

        Claims::Payment::UpdateClaimWithPayerResponseJob.perform_later(updated_details_for_claim, notification_wait_time:, response:)
      end
    end
  end

  private

  def payment_in_progress_claims(ids)
    Claims::Claim.payment_in_progress.where(id: ids)
  end
end
