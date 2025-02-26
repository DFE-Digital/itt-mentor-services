class AddReferencesToPlacementLocationProviders < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_reference :placement_location_providers, :placement, null: true, type: :uuid, index: { algorithm: :concurrently }
    add_reference :placement_location_providers, :provider, null: true, type: :uuid, index: { algorithm: :concurrently }
  end
end
