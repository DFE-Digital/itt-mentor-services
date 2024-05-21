class AddParentSubjectToSubjects < ActiveRecord::Migration[7.1]
  def change
    StrongMigrations.disable_check(:add_reference)

    add_reference :subjects, :parent_subject, type: :uuid, foreign_key: { to_table: :subjects }
  end
end
