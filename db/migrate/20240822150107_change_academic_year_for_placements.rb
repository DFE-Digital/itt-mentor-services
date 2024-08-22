class ChangeAcademicYearForPlacements < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :placements, "academic_year_id IS NOT NULL", name: "placements_academic_year_id_null", validate: false
  end
end
