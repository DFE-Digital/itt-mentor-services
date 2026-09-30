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
                 subject: t(".subject"),
                 body: t(
                   ".body",
                   provider_name: @provider_sampling.provider_name,
                   download_csv_url: claims_sampling_claims_url(token:, utm_source: "email", utm_medium: "notification", utm_campaign: "provider"),
                   support_email:, service_name:, completion_date:, service_url: claims_root_url(utm_source: "email", utm_medium: "notification", utm_campaign: "provider")
                 )
  end

  def claims_have_not_been_submitted(user_membership)
    claim_window = Claims::ClaimWindow.current
    academic_year_name = claim_window.academic_year_name
    deadline = l(claim_window.ends_on, format: :long)

    notify_email to: user_membership.user.email,
                 subject: t(".subject", deadline:),
                 body: t(
                   ".body",
                   claim_window: Claims::ClaimWindow.current,
                   provider_name: user_membership.organisation.name,
                   deadline:,
                   academic_year_name:,
                   service_name:,
                   support_email:,
                   sign_in_url: sign_in_url(utm_source: "email", utm_medium: "notification", utm_campaign: "school"),
                 )
  end

  private

  attr_reader :provider_sampling, :provider_user

  def token
    Claims::DownloadAccessToken.create!(activity_record: provider_sampling, email_address: provider_user.email).generate_token_for(:csv_download)
  end

  def number_of_claims
    count = provider_sampling.claims.count
    "#{count} #{"claim".pluralize(count)}"
  end

  def completion_date
    date = Date.current + 30.days
    date = date.next_weekday if date.on_weekend?
    date.strftime("%d %B %Y")
  end
end
