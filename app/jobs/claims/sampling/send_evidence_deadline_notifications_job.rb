class Claims::Sampling::SendEvidenceDeadlineNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    notification_schedule = NotifyRateLimiter::Schedule.new

    Claims::Claim.sampling_provider_not_approved
      .where(amendment_deadline_notification_sent_at: nil)
      .where.not(amendment_notification_sent_at: nil)
      .find_each do |claim|
      claim.with_lock do
        next if claim.amendment_deadline_notification_sent_at.present?
        next unless claim.amendment_deadline_passed?

        delivery = Claims::UserMailer.claim_amendment_evidence_deadline_passed_notification(claim.created_by, claim)
          .deliver_later(wait: notification_schedule.reserve(1))
        raise ActiveJob::EnqueueError, "Could not enqueue evidence deadline notification for claim #{claim.id}" unless delivery

        claim.update!(amendment_deadline_notification_sent_at: Time.current)
      end
    end
  end
end
