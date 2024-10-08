# == Schema Information
#
# Table name: user_memberships
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
#  index_memberships_on_organisation                      (organisation_type,organisation_id)
#  index_user_memberships_on_user_id                      (user_id)
#  index_user_memberships_on_user_id_and_organisation_id  (user_id,organisation_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :user_membership do
    association :user, factory: :claims_user
    association :organisation, factory: :school
  end
end
