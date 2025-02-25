class CreateProviderCourses < ActiveRecord::Migration[7.2]
  def change
    create_table :provider_courses, id: :uuid, &:timestamps
  end
end
