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
FactoryBot.define do
  factory :placement_location_provider do
  end
end
