class DropPlacementSubjectJoins < ActiveRecord::Migration[7.1]
  def up
    drop_table :placement_subject_joins
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
