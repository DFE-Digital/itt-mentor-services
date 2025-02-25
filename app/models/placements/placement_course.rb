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
class Placements::PlacementCourse < ApplicationRecord
  belongs_to :placement
  belongs_to :course
end
