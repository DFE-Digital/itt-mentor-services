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
require "rails_helper"

RSpec.describe PlacementSubjectJoin, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:placement) }
    it { is_expected.to belong_to(:subject) }
  end
end
