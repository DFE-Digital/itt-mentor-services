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
#  index_memberships_on_organisation  (organisation_type,organisation_id)
#  index_memberships_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :membership do
    association :user
    association :organisation, factory: :school
  end
end
