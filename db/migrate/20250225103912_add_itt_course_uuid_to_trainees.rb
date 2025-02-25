class AddIttCourseUuidToTrainees < ActiveRecord::Migration[7.2]
  def change
    add_column :trainees, :itt_course_uuid, :string
  end
end
