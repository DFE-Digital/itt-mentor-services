# == Schema Information
#
# Table name: provider_samplings
#
#  id            :uuid             not null, primary key
#  downloaded_at :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  provider_id   :uuid             not null
#  sampling_id   :uuid             not null
#
# Indexes
#
#  index_provider_samplings_on_provider_id  (provider_id)
#  index_provider_samplings_on_sampling_id  (sampling_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (sampling_id => samplings.id)
#
FactoryBot.define do
  factory :provider_sampling, class: "Claims::ProviderSampling" do
    association :sampling, factory: :claims_sampling
    association :provider, factory: :claims_provider

    csv_file { file_fixture("example-sampling-response.csv") }
  end
end
