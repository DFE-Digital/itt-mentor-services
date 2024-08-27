# == Schema Information
#
# Table name: placement_windows
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  placement_id :uuid             not null
#  term_id      :uuid             not null
#
# Indexes
#
#  index_placement_windows_on_placement_id  (placement_id)
#  index_placement_windows_on_term_id       (term_id)
#
# Foreign Keys
#
#  fk_rails_...  (placement_id => placements.id)
#  fk_rails_...  (term_id => terms.id)
#
require "rails_helper"

RSpec.describe Placements::PlacementWindow, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:placement) }
    it { is_expected.to belong_to(:term) }
  end
end
