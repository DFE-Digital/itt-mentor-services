class AddForeignKeyToCourseSubjectId < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :courses, :subjects, column: :subject_id, primary_key: :id, type: :uuid, validate: false
  end
end
