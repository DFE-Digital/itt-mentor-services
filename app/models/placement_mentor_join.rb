# == Schema Information
#
# Table name: placement_mentor_joins
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  mentor_id    :uuid             not null
#  placement_id :uuid             not null
#
# Indexes
#
#  index_placement_mentor_joins_on_mentor_id     (mentor_id)
#  index_placement_mentor_joins_on_placement_id  (placement_id)
#
# Foreign Keys
#
#  fk_rails_...  (mentor_id => mentors.id)
#  fk_rails_...  (placement_id => placements.id)
#
class PlacementMentorJoin < ApplicationRecord
  belongs_to :placement
  belongs_to :mentor, class_name: "Placements::Mentor"
end
