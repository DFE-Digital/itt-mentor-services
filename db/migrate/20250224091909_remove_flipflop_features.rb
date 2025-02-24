class RemoveFlipflopFeatures < ActiveRecord::Migration[7.2]
  def change
    drop_table :flipflop_features do |t|
      t.string :key, null: false
      t.boolean "enabled", default: false, null: false

      t.timestamps null: false
    end
  end
end
