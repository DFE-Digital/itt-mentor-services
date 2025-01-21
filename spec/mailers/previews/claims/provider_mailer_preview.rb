class Claims::ProviderMailerPreview < ActionMailer::Preview
  def sampling_checks_required
    Claims::ProviderMailer.sampling_checks_required(Claims::ProviderSampling.first)
  end
end
