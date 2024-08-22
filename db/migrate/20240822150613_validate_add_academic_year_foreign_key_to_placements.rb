class ValidateAddAcademicYearForeignKeyToPlacements < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :placements, :academic_years
  end
end
