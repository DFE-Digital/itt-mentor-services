class Claims::ProviderMailerPreview < ActionMailer::Preview
  include ActionDispatch::TestProcess::FixtureFile

  def sampling_checks_required
    Claims::ProviderMailer.sampling_checks_required(provider_sampling, email_address: "example@example.com")
  end

  def resend_sampling_checks_required
    Claims::ProviderMailer.resend_sampling_checks_required(provider_sampling, email_address: "example@example.com")
  end

  private

  def provider_sampling
    @provider_sampling ||= FactoryBot.build_stubbed(:provider_sampling, csv_file: nil, sampling: nil)
  end

  def provider
    FactoryBot.build_stubbed(:claims_provider)
  end
end
