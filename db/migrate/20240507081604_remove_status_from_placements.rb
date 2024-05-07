class RemoveStatusFromPlacements < ActiveRecord::Migration[7.1]
  def change
    remove_column :placements, :status, :string
  end
end
