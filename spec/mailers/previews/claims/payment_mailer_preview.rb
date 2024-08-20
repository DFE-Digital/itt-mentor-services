class Claims::PaymentMailerPreview < ActionMailer::Preview
  def payment_created_notification
    Claims::PaymentMailer.with(service: :claims).payment_created_notification(Claims::Payment.first)
  end
end
