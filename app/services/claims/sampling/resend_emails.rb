class Claims::Sampling::ResendEmails < ApplicationService
  def initialize(provider_sampling:, email_addresses: provider_sampling.provider_email_addresses)
    @provider_sampling = provider_sampling
    @email_addresses = email_addresses
  end

  def call
    validate_email_addresses
    provider_sampling.transaction do
      provider_sampling.download_access_tokens.where(email_address: email_addresses).destroy_all

      email_addresses.each do |email_address|
        Claims::ProviderMailer.resend_sampling_checks_required(provider_sampling, email_address:).deliver_later
      end
    end
  end

  private

  attr_reader :provider_sampling, :email_addresses

  def validate_email_addresses
    raise InvalidEmailAddressesError unless (email_addresses - provider_sampling.provider_email_addresses).empty?
  end

  class InvalidEmailAddressesError < StandardError; end
end
