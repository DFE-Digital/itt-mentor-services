class Claims::ProviderMailerPreview < ActionMailer::Preview
  include ActionDispatch::TestProcess::FixtureFile

  def sampling_checks_required
    Claims::ProviderMailer.sampling_checks_required("example@example.com", provider_sampling)
  end

  def resend_sampling_checks_required
    Claims::ProviderMailer.resend_sampling_checks_required("example@example.com", provider_sampling)
  end

  def claims_have_not_been_submitted
    Claims::ProviderMailer.claims_have_not_been_submitted(email_address_record)
  end

  private

  def provider_sampling
    @provider_sampling ||= Claims::ProviderSampling.new(id: stubbed_id, provider:)
  end

  def email_address_record
    @email_address_record ||= Claims::ProviderEmailAddress.new(
      id: stubbed_id,
      provider:,
      email_address: "test.provider@example.com",
    )
  end

  def provider
    Claims::Provider.new(id: stubbed_id, name: "Test Provider")
  end

  def stubbed_id
    SecureRandom.uuid
  end
end
