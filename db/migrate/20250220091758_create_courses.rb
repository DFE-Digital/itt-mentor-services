class CreateCourses < ActiveRecord::Migration[7.2]
  def change
    create_table :courses, id: :uuid do |t|
      t.string :code
      t.string :subject_code

      t.timestamps
    end
  end
end
