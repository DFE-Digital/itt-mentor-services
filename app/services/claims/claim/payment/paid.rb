class Claims::Claim::Payment::Paid < ApplicationService
  def initialize(claim:, paid_to_la: nil, date_paid: nil)
    @claim = claim
    @paid_to_la = paid_to_la
    @date_paid = date_paid
  end

  def call
    claim.update!(status: :paid, paid_to_la:, date_paid:)

    NotifyRateLimiter.call(
      batch_size: 1,
      collection: claim.school_users,
      mailer: "Claims::UserMailer",
      mailer_method: :claim_payment_in_progress_notification,
      mailer_args: [claim],
    )
  end

  private

  attr_reader :claim, :paid_to_la, :date_paid
end
