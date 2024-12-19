class Claims::PaymentMailer < Claims::ApplicationMailer
  def payment_created_notification(payment)
    @payment = payment

    notify_email to: esfa_email_addresses,
                 from: support_email,
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   download_page_url: claims_payments_claims_url(token:),
                   support_email:,
                 )
  end

  private

  def esfa_email_addresses
    ENV.fetch("CLAIMS_ESFA_EMAIL_ADDRESSES").split(",")
  end

  def token
    Rails.application.message_verifier(:payments).generate(@payment.id, expires_in: 7.days)
  end
end
