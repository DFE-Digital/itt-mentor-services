class CreatePlacements < ActiveRecord::Migration[7.1]
  def change
    create_enum :placement_status, %w[draft published]

    create_table :placements, id: :uuid do |t|
      t.enum :status, enum_type: "placement_status"
      t.date :start_date
      t.date :end_date
      t.references :school, null: true, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
