class ValidateChangeAcademicYearForPlacements < ActiveRecord::Migration[7.1]
  def up
    validate_check_constraint :placements, name: "placements_academic_year_id_null"
    change_column_null :placements, :academic_year_id, false
    remove_check_constraint :placements, name: "placements_academic_year_id_null"
  end

  def down
    add_check_constraint :placements, "academic_year_id IS NOT NULL", name: "placements_academic_year_id_null", validate: false
    change_column_null :placements, :academic_year_id, true
  end
end
