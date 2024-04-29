# == Schema Information
#
# Table name: placements
#
#  id         :uuid             not null, primary key
#  status     :enum             default("draft")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :uuid
#
# Indexes
#
#  index_placements_on_school_id  (school_id)
#
# Foreign Keys
#
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
