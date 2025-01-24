class Claims::ProviderMailerPreview < ActionMailer::Preview
  def sampling_checks_required
    Claims::ProviderMailer.sampling_checks_required(Claims::ProviderSampling.first, email_address: "example@example.com")
  end

  def resend_sampling_checks_required
    Claims::ProviderMailer.resend_sampling_checks_required(Claims::ProviderSampling.first, email_address: "example@example.com")
  end
end
