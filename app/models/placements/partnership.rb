# == Schema Information
#
# Table name: partnerships
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :uuid             not null
#  school_id   :uuid             not null
#
# Indexes
#
#  index_partnerships_on_provider_id                (provider_id)
#  index_partnerships_on_school_id                  (school_id)
#  index_partnerships_on_school_id_and_provider_id  (school_id,provider_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#
class Placements::Partnership < ApplicationRecord
  belongs_to :provider
  belongs_to :school

  validates :school_id, uniqueness: { scope: :provider_id }
end
