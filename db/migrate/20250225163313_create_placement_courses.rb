class CreatePlacementCourses < ActiveRecord::Migration[7.2]
  def change
    create_table :placement_courses, id: :uuid, &:timestamps
  end
end
