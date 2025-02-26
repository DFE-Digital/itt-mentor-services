class AddForeignKeyToTraineesCourseId < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :trainees, :courses, column: :course_id, primary_key: :id, type: :uuid, validate: false
  end
end
