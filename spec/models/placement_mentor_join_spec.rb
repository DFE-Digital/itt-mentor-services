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
require "rails_helper"

RSpec.describe PlacementMentorJoin, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:placement) }
    it { is_expected.to belong_to(:mentor) }
  end
end
