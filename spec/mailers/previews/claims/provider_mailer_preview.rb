class Claims::ProviderMailerPreview < ActionMailer::Preview
  def sampling_checks_required
    Claims::ProviderMailer.sampling_checks_required(Claims::Provider.first, "https://example.com")
  end
end
