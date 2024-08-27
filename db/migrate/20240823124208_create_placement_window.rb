class CreatePlacementWindow < ActiveRecord::Migration[7.1]
  def change
    create_table :placement_windows, id: :uuid do |t|
      t.references :placement, null: false, foreign_key: true, type: :uuid
      t.references :term, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
