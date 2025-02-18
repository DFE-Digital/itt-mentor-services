class Claims::PaymentMailerPreview < ActionMailer::Preview
  def payment_created_notification
    Claims::PaymentMailer.payment_created_notification(payment)
  end

  def resend_payment_created_notification
    Claims::PaymentMailer.resend_payment_created_notification(payment)
  end

  private

  def payment
    FactoryBot.build_stubbed(:claims_payment, csv_file: nil)
  end
end
