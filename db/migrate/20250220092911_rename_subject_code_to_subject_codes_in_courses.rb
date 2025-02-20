class RenameSubjectCodeToSubjectCodesInCourses < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      remove_column :courses, :subject_code
    end
    add_column :courses, :subject_codes, :string
  end
end
