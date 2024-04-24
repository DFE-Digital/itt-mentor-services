class AddProviderToPlacement < ActiveRecord::Migration[7.1]
  def change
    add_reference :placements, :provider, null: true, foreign_key: true, type: :uuid
  end
end
