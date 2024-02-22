# == Schema Information
#
# Table name: placement_subject_joins
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  placement_id :uuid             not null
#  subject_id   :uuid             not null
#
# Indexes
#
#  index_placement_subject_joins_on_placement_id  (placement_id)
#  index_placement_subject_joins_on_subject_id    (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (placement_id => placements.id)
#  fk_rails_...  (subject_id => subjects.id)
#
class PlacementSubjectJoin < ApplicationRecord
  belongs_to :placement
  belongs_to :subject
end
