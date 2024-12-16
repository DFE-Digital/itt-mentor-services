class Claims::ESFAMailer < Claims::ApplicationMailer
  def claims_require_clawback(url_for_csv)
    notify_email to: esfa_email_addresses,
                 subject: t(".subject"),
                 body: t(".body", url_for_csv:, support_email:, service_name:)
  end

  private

  def esfa_email_addresses
    ENV["CLAIMS_ESFA_EMAIL_ADDRESSES"].split(",")
  end
end
