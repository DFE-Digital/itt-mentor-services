# == Schema Information
#
# Table name: providers
#
#  id               :uuid             not null, primary key
#  city             :string
#  county           :string
#  email            :string
#  name             :string           not null
#  placements       :boolean          default(FALSE)
#  postcode         :string
#  provider_code    :string           not null
#  provider_type    :enum             not null
#  street_address_1 :string
#  street_address_2 :string
#  street_address_3 :string
#  telephone        :string
#  town             :string
#  ukprn            :string
#  urn              :string
#  website          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_providers_on_placements     (placements)
#  index_providers_on_provider_code  (provider_code) UNIQUE
#
FactoryBot.define do
  factory :provider do
    # Provider codes are 3 character alphanumeric strings – e.g. "T92"
    # Since they're derived from a sequence, they're guaranteed to be unique.
    sequence(:provider_code) { |n| n.to_s(36).rjust(3, "0").upcase }

    name { Faker::University.name }
    provider_type { Provider.provider_types.keys.sample }

    trait :scitt do
      provider_type { "scitt" }
    end

    trait :lead_school do
      provider_type { "lead_school" }
    end

    trait :university do
      provider_type { "university" }
    end
  end
end
