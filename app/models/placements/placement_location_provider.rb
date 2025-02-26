# == Schema Information
#
# Table name: placement_location_providers
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  placement_id :uuid
#  provider_id  :uuid
#
# Indexes
#
#  index_placement_location_providers_on_placement_id  (placement_id)
#  index_placement_location_providers_on_provider_id   (provider_id)
#
class Placements::PlacementLocationProvider < ApplicationRecord
  belongs_to :placement
  belongs_to :provider, class_name: "Placements::Provider"

  def self.populate_placement_location_providers
    Placement.all.find_each do |placement|
      matching_providers = Provider.where(town: placement.school.town)

      matching_providers.each do |provider|
        unless Placements::PlacementLocationProvider.exists?(placement_id: placement.id, provider_id: provider.id)
          Placements::PlacementLocationProvider.create!(placement_id: placement.id, provider_id: provider.id)
        end
      end
    end
  end
end
