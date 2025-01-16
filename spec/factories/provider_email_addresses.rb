# == Schema Information
#
# Table name: provider_email_addresses
#
#  id            :uuid             not null, primary key
#  email_address :string
#  primary       :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  provider_id   :uuid             not null
#
# Indexes
#
#  index_provider_email_addresses_on_primary      (primary)
#  index_provider_email_addresses_on_provider_id  (provider_id)
#  unique_provider_email                          (email_address,provider_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#
FactoryBot.define do
  factory :provider_email_address do
    association :provider
    sequence(:email_address) { |n| "provider_email#{n}@example.com" }
  end
end
