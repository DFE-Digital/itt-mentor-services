# == Schema Information
#
# Table name: providers
#
#  id                 :uuid             not null, primary key
#  accredited         :boolean          default(FALSE)
#  address1           :string
#  address2           :string
#  address3           :string
#  city               :string
#  code               :string           not null
#  county             :string
#  latitude           :float
#  longitude          :float
#  name               :string           default(""), not null
#  placements_service :boolean          default(FALSE)
#  postcode           :string
#  provider_type      :enum             default("scitt"), not null
#  telephone          :string
#  town               :string
#  ukprn              :string
#  urn                :string
#  website            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_providers_on_code                (code) UNIQUE
#  index_providers_on_latitude            (latitude)
#  index_providers_on_longitude           (longitude)
#  index_providers_on_name_trigram        (name) USING gin
#  index_providers_on_placements_service  (placements_service)
#  index_providers_on_postcode_trigram    (postcode) USING gin
#  index_providers_on_provider_type       (provider_type)
#  index_providers_on_ukprn_trigram       (ukprn) USING gin
#  index_providers_on_urn_trigram         (urn) USING gin
#
FactoryBot.define do
  factory :provider do
    # Provider codes are 3 character alphanumeric strings – e.g. "T92"
    # Since they're derived from a sequence, they're guaranteed to be unique.
    sequence(:code) { |n| n.to_s(36).rjust(3, "0").upcase }

    name { Faker::University.name }
    provider_type { Provider.provider_types.keys.sample }

    trait :scitt do
      provider_type { :scitt }
    end

    trait :lead_school do
      provider_type { :lead_school }
    end

    trait :university do
      provider_type { :university }
    end

    trait :placements do
      placements_service { true }
    end

    trait :best_practice_network do
      name { "Best Practice Network" }
    end

    trait :niot do
      name { "NIoT: National Institute of Teaching, founded by the School-Led Development Trust" }
    end

    transient do
      email_addresses { [] }
    end

    after(:create) do |provider, evaluator|
      if evaluator.email_addresses.present?
        evaluator.email_addresses.each_with_index do |email_address, i|
          create(:provider_email_address,
                 email_address:,
                 provider:,
                 primary: i.zero?)
        end
      else
        create(:provider_email_address,
               email_address: "#{provider.name.split(" ").join("_").downcase.gsub(/[^a-zA-Z0-9-]_/, "")}@example.com",
               provider:,
               primary: true)
      end
    end
  end

  factory :claims_provider, class: "Claims::Provider", parent: :provider
  factory :placements_provider, class: "Placements::Provider", parent: :provider, traits: %i[placements]
end
