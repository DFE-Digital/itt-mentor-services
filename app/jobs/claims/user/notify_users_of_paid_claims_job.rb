class Claims::User::NotifyUsersOfPaidClaimsJob < ApplicationJob
  queue_as :default

  def perform
    Claims::Claim.awaiting_paid_notification.find_each do |claim|
      NotifyRateLimiter.call(
        batch_size: 1,
        collection: claim.school_users,
        mailer: "Claims::UserMailer",
        mailer_method: :claim_paid_notification,
        mailer_args: [claim],
      )

      claim.update!(paid_notification_sent_at: Time.current)
    end
  end
end
