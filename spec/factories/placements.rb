# == Schema Information
#
# Table name: placements
#
#  id          :uuid             not null, primary key
#    status      :enum             default("draft")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :uuid
#  school_id   :uuid
#
# Indexes
#
#  index_placements_on_provider_id  (provider_id)
#  index_placements_on_school_id    (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#
FactoryBot.define do
  factory :placement do
    association :school, factory: :placements_school
    status { :published }

    trait :draft do
      status { :draft }
    end
  end
end
