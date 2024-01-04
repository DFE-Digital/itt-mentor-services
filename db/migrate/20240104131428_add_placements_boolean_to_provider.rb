class AddPlacementsBooleanToProvider < ActiveRecord::Migration[7.1]
  def change
    change_table :providers do |t|
      t.boolean :placements, default: false, index: true
    end
  end
end
