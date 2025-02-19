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
    @provider_sampling ||= Claims::ProviderSampling.new(id: stubbed_id, provider:)
  end

  def provider
    Claims::Provider.new(id: stubbed_id, name: "Test Provider")
  end

  def stubbed_id
    SecureRandom.uuid
  end
end
