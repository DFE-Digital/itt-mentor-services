class BackfillPlacementsAcademicYear < ActiveRecord::Migration[7.1]
  def up
    Placement.update_all(academic_year_id: Placements::AcademicYear.current.id)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
