# == Schema Information
#
# Table name: provider_samplings
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :uuid             not null
#  sampling_id :uuid             not null
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
class Claims::ProviderSampling < ApplicationRecord
  belongs_to :sampling
  belongs_to :provider

  has_many :provider_sampling_claims
  has_many :claims, through: :provider_sampling_claims

  has_one_attached :csv_file

  delegate :email_address, :name, to: :provider, prefix: true
end
