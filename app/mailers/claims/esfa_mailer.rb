class Claims::ESFAMailer < Claims::ApplicationMailer
  def claims_require_clawback(clawback)
    @clawback = clawback

    notify_email to: esfa_email_addresses,
                 subject: t(".subject"),
                 body: t(".body", url_for_csv: download_claims_clawback_claims_url(token:), support_email:, service_name:)
  end

  private

  def esfa_email_addresses
    ENV["CLAIMS_ESFA_EMAIL_ADDRESSES"].split(",")
  end

  def token
    Rails.application.message_verifier(:clawback).generate(@clawback.id, expires_in: 7.days)
  end
end
