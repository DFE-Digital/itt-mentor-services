class AddCreatorToPlacements < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :placements, :creator, polymorphic: true, type: :uuid, index: { algorithm: :concurrently }
  end
end
