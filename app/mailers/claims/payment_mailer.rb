class Claims::PaymentMailer < ApplicationMailer
  def payment_created_notification(payment)
    notify_email to: esfa_email_addresses,
                 from: t("claims.support_email"),
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   link_to: download_claims_payments_claims_url(token: message_verifier.generate(payment.id, expires_at:)),
                   service_name:,
                 )
  end

  private

  def esfa_email_addresses
    ENV["CLAIMS_ESFA_EMAIL_ADDRESSES"].split(",")
  end

  def message_verifier
    Rails.application.message_verifier(:payment)
  end

  def expires_at
    30.days.from_now
  end
end
