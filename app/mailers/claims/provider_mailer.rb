class Claims::ProviderMailer < Claims::ApplicationMailer
  def sampling_checks_required(provider, url_for_csv)
    notify_email to: provider.email_address,
                 subject: t(".subject"),
                 body: t(".body", provider_name: provider.name, url_for_csv:, support_email:, service_name:)
  end
end
