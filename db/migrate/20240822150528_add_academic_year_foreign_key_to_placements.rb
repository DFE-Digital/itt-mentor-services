class AddAcademicYearForeignKeyToPlacements < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :placements, :academic_years, validate: false
  end
end
