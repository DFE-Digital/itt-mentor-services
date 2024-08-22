class AddAcademicYearIndexToPlacements < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :placements, :academic_year
  end
end
