class Claims::ProviderMailer < Claims::ApplicationMailer
  def sampling_checks_required(provider_sampling, email_address:)
    @provider_sampling = provider_sampling
    @email_address = email_address

    notify_email to: email_address,
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   provider_name: @provider_sampling.provider_name,
                   download_csv_url: claims_sampling_claims_url(token:, utm_source: "email", utm_medium: "notification", utm_campaign: "provider"),
                   support_email:, service_name:, completion_date:, service_url: claims_root_url(utm_source: "email", utm_medium: "notification", utm_campaign: "provider")
                 )
  end

  def resend_sampling_checks_required(provider_sampling, email_address:)
    @provider_sampling = provider_sampling
    @email_address = email_address

    notify_email to: email_address,
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   provider_name: @provider_sampling.provider_name,
                   download_csv_url: claims_sampling_claims_url(token:, utm_source: "email", utm_medium: "notification", utm_campaign: "provider"),
                   support_email:, service_name:, completion_date:, service_url: claims_root_url(utm_source: "email", utm_medium: "notification", utm_campaign: "provider")
                 )
  end

  def claims_have_not_been_submitted(provider_name:, email_address:)
    claim_window = Claims::ClaimWindow.current
    academic_year_name = claim_window.academic_year_name
    deadline = l(claim_window.ends_on, format: :long)

    notify_email to: email_address,
                 subject: t(".subject", deadline:),
                 body: t(
                   ".body",
                   claim_window: Claims::ClaimWindow.current,
                   next_claim_window_opens: l(Claims::ClaimWindow.next.starts_on, format: :long),
                   provider_name:,
                   deadline:,
                   academic_year_name:,
                   service_name:,
                   support_email:,
                   sign_in_url: sign_in_url(utm_source: "email", utm_medium: "notification", utm_campaign: "school"),
                 )
  end

  private

  attr_reader :provider_sampling, :email_address

  def token
    Claims::DownloadAccessToken.create!(activity_record: provider_sampling, email_address:).generate_token_for(:csv_download)
  end

  def completion_date
    date = Date.current
    date = date.next_weekday if date.on_weekend?
    (date + 30.days).strftime("%d %B %Y")
  end
end
