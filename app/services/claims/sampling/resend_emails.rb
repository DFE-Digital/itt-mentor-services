class Claims::Sampling::ResendEmails < ApplicationService
  def initialize(provider_sampling:, provider_users: provider_sampling.provider_users)
    @provider_sampling = provider_sampling
    @provider_users = provider_users
  end

  def call
    validate_provider_users
    provider_sampling.transaction do
      provider_sampling.download_access_tokens.where(email_address: provider_users.map(&:email)).destroy_all

      provider_users.each do |provider_user|
        Claims::ProviderMailer.sampling_checks_required(provider_sampling, provider_user).deliver_later
      end
    end
  end

  private

  attr_reader :provider_sampling, :provider_users

  def validate_provider_users
    raise InvalidProviderUsersError unless (provider_users.to_a - provider_sampling.provider_users.to_a).empty?
  end

  class InvalidProviderUsersError < StandardError; end
end
