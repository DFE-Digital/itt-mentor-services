class CreatePlacementSubjectJoins < ActiveRecord::Migration[7.1]
  def change
    create_table :placement_subject_joins, id: :uuid do |t|
      t.references :subject, null: false, foreign_key: true, type: :uuid
      t.references :placement, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
