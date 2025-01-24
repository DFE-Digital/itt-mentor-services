class Claims::ProviderMailer < Claims::ApplicationMailer
  def sampling_checks_required(provider_sampling, email_address:)
    @provider_sampling = provider_sampling
    @email_address = email_address

    notify_email to: email_address,
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   provider_name: @provider_sampling.provider_name,
                   download_csv_url: claims_sampling_claims_url(token:),
                   support_email:, service_name:, completion_date:, service_url: claims_root_url
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
                   download_csv_url: claims_sampling_claims_url(token:),
                   support_email:, service_name:, completion_date:, service_url: claims_root_url
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
