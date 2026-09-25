class Claims::Claim::Payment::Paid < ApplicationService
  def initialize(claim:, paid_to_la: nil, date_paid: nil, notification_wait_time: 0.minutes)
    @claim = claim
    @paid_to_la = paid_to_la
    @date_paid = date_paid
    @notification_wait_time = notification_wait_time
  end

  def call
    claim.update!(status: :paid, paid_to_la:, date_paid:)

    NotifyRateLimiter.call(
      collection: claim.school_users,
      mailer: "Claims::UserMailer",
      mailer_method: :claim_payment_in_progress_notification,
      mailer_args: [claim],
      initial_wait_time: notification_wait_time,
    )
  end

  private

  attr_reader :claim, :paid_to_la, :date_paid, :notification_wait_time
end
