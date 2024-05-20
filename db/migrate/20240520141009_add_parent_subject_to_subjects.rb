class AddParentSubjectToSubjects < ActiveRecord::Migration[7.1]
  def change
    add_reference :subjects, :parent_subject, type: :uuid, foreign_key: { to_table: :subjects }
  end
end
