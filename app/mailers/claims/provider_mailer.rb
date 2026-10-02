class Claims::ProviderMailer < Claims::ApplicationMailer
  def sampling_checks_required(provider_sampling, provider_user)
    @provider_sampling = provider_sampling
    @provider_user = provider_user

    notify_email to: provider_user.email,
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   provider_name: @provider_sampling.provider_name,
                   number_of_claims:,
                   support_email:, completion_date:, service_url: claims_root_url(utm_source: "email", utm_medium: "notification", utm_campaign: "provider")
                 )
  end

  def resend_sampling_checks_required(provider_sampling, provider_user)
    @provider_user = provider_user
    @provider_sampling = provider_sampling

    notify_email to: provider_user.email,
                 subject: t(".subject", completion_date:),
                 body: t(
                   ".body",
                   provider_name: @provider_sampling.provider_name,
                   number_of_claims: number_of_claims(provider_sampling.claims.sampling_in_progress),
                   support_email:, completion_date:, service_url: claims_root_url(utm_source: "email", utm_medium: "notification", utm_campaign: "provider")
                 )
  end

  private

  attr_reader :provider_sampling, :provider_user

  def number_of_claims(claims = provider_sampling.claims)
    count = claims.count
    "#{count} #{"claim".pluralize(count)}"
  end

  def completion_date
    date = provider_sampling.created_at.to_date + 30.days
    date = date.next_weekday if date.on_weekend?
    date.strftime("%d %B %Y")
  end
end
