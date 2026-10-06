# == Schema Information
#
# Table name: provider_eligibilities
#
#  id               :uuid             not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  academic_year_id :uuid             not null
#  provider_id      :uuid             not null
#
# Indexes
#
#  index_provider_eligibilities_on_academic_year_id            (academic_year_id)
#  index_provider_eligibilities_on_provider_and_academic_year  (provider_id,academic_year_id) UNIQUE
#  index_provider_eligibilities_on_provider_id                 (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_id => academic_years.id)
#  fk_rails_...  (provider_id => providers.id)
#
class Claims::ProviderEligibility < ApplicationRecord
  belongs_to :provider, class_name: "::Provider"
  belongs_to :academic_year

  validates :provider_id, uniqueness: { scope: :academic_year_id }
end
