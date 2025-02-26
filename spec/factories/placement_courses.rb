# == Schema Information
#
# Table name: placement_courses
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  placement_id :uuid
#
# Indexes
#
#  index_placement_courses_on_placement_id  (placement_id)
#
FactoryBot.define do
  factory :placement_course do
  end
end
