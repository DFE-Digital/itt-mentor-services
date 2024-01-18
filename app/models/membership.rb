# == Schema Information
#
# Table name: memberships
#
#  id                :uuid             not null, primary key
#  organisation_type :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organisation_id   :uuid             not null
#  user_id           :uuid             not null
#
# Indexes
#
#  index_memberships_on_organisation                 (organisation_type,organisation_id)
#  index_memberships_on_user_id                      (user_id)
#  index_memberships_on_user_id_and_organisation_id  (user_id,organisation_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organisation, polymorphic: true

  validates :organisation_id, uniqueness: { scope: :user }
end
