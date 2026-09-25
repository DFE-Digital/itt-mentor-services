class Claims::User::NotifyUsersOfPaidClaimsJob < ApplicationJob
  queue_as :default

  def perform
    notification_schedule = NotifyRateLimiter::Schedule.new

    Claims::Claim.awaiting_paid_notification.find_each do |claim|
      NotifyRateLimiter.call(
        collection: claim.school_users,
        mailer: "Claims::UserMailer",
        mailer_method: :claim_paid_notification,
        mailer_args: [claim],
        initial_wait_time: notification_schedule.reserve(claim.school_users.count),
      )

      claim.update!(paid_notification_sent_at: Time.current)
    end
  end
end
