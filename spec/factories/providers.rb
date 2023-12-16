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
FactoryBot.define do
  factory :provider do
    provider_code { SecureRandom.hex(5) }
  end
end
