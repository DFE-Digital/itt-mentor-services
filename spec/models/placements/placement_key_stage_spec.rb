# == Schema Information
#
# Table name: placement_key_stages
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  key_stage_id :uuid             not null
#  placement_id :uuid             not null
#
# Indexes
#
#  index_placement_key_stages_on_key_stage_id  (key_stage_id)
#  index_placement_key_stages_on_placement_id  (placement_id)
#
# Foreign Keys
#
#  fk_rails_...  (key_stage_id => key_stages.id)
#  fk_rails_...  (placement_id => placements.id)
#
require "rails_helper"

RSpec.describe Placements::PlacementKeyStage, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:placement) }
    it { is_expected.to belong_to(:key_stage).class_name("Placements::KeyStage") }
  end
end
