# == Schema Information
#
# Table name: providers
#
#  id            :uuid             not null, primary key
#  provider_code :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_providers_on_provider_code  (provider_code) UNIQUE
#
class Provider < ApplicationRecord
  has_many :memberships, as: :organisation

  validates :provider_code, presence: true
  validates :provider_code, uniqueness: { case_sensitive: false }

  def method_missing(method, *args, &block)
    if provider_details.keys.include?(method.to_s)
      provider_details.fetch(method&.to_s, nil)
    else
      super
    end
  end

  def respond_to_missing?(method, include_private = true)
    provider_details.keys.include?(method.to_s) || super
  end

  def provider_details
    provider_api.fetch("attributes", {})
  end

  def provider_api
    @provider_api ||= AccreditedProviderApi.call(provider_code)
  end
end
