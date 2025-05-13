class CreatePlacementKeyStages < ActiveRecord::Migration[7.2]
  def change
    create_table :placement_key_stages, id: :uuid do |t|
      t.references :placement, null: false, foreign_key: true, type: :uuid
      t.references :key_stage, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
