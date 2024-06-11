class AddIndexesToPlacements < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :placements, :year_group, algorithm: :concurrently
  end
end
