class CreatePlacementLocationProviders < ActiveRecord::Migration[7.2]
  def change
    create_table :placement_location_providers, id: :uuid, &:timestamps
  end
end
