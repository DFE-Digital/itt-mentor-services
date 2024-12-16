class Claims::ESFAMailer < Claims::ApplicationMailer
  ESFA_EMAIL_ADDRESS = "esfa@example.com".freeze
  private_constant :ESFA_EMAIL_ADDRESS

  def claims_require_clawback(url_for_csv)
    notify_email to: ESFA_EMAIL_ADDRESS,
                 subject: t(".subject"),
                 body: t(".body", url_for_csv:, support_email:, service_name:)
  end
end
