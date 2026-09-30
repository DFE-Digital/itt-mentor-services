class Claims::ProviderMailerPreview < ActionMailer::Preview
  include ActionDispatch::TestProcess::FixtureFile

  def sampling_checks_required
    Claims::ProviderMailer.sampling_checks_required(provider_sampling, provider_user)
  end

  def resend_sampling_checks_required
    Claims::ProviderMailer.resend_sampling_checks_required(provider_sampling, provider_user)
  end

  def claims_have_not_been_submitted
    Claims::ProviderMailer.claims_have_not_been_submitted(user_membership)
  end

  private

  def provider_sampling
    @provider_sampling ||= Claims::ProviderSampling.new(id: stubbed_id, provider:)
  end

  def user_membership
    @user_membership ||= UserMembership.new(id: stubbed_id, user: provider_user, organisation: provider)
  end

  def provider_user
    @provider_user ||= Claims::ProviderUser.new(
      id: stubbed_id,
      first_name: "Test",
      last_name: "User",
      email: "test.provider@example.com",
    )
  end

  def provider
    Claims::Provider.new(id: stubbed_id, name: "Test Provider")
  end

  def stubbed_id
    SecureRandom.uuid
  end
end
