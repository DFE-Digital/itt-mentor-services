class Claims::PaymentMailerPreview < ActionMailer::Preview
  def payment_created_notification
    Claims::PaymentMailer.payment_created_notification(payment)
  end

  def resend_payment_created_notification
    Claims::PaymentMailer.resend_payment_created_notification(payment)
  end

  private

  def payment
    Claims::Payment.order(created_at: :desc).first_or_initialize(id: SecureRandom.uuid)
  end
end
