class BackfillPlacementsAcademicYear < ActiveRecord::Migration[7.1]
  def up
    Placement.find_each do |placement|
      placement.update(academic_year_id: Placements::AcademicYear.current.id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
