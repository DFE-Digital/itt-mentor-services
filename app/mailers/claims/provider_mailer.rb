class Claims::ProviderMailer < Claims::ApplicationMailer
  def sampling_checks_required(provider_sampling)
    @provider_sampling = provider_sampling

    notify_email to: @provider_sampling.provider_email_addresses,
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   provider_name: @provider_sampling.provider_name,
                   download_csv_url: claims_sampling_claims_url(token:),
                   support_email:, service_name:, completion_date:, service_url: claims_root_url
                 )
  end

  private

  attr_reader :provider_sampling

  def token
    Rails.application.message_verifier(:sampling).generate(provider_sampling.id, expires_in: 7.days)
  end

  def completion_date
    date = Date.current
    date = date.next_weekday if date.on_weekend?
    (date + 30.days).strftime("%d %B %Y")
  end
end
