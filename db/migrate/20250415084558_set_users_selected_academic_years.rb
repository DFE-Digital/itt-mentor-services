class SetUsersSelectedAcademicYears < ActiveRecord::Migration[7.2]
  def up
    selected_academic_year_id = Placements::AcademicYear.current.next.id

    Placements::User.update_all(selected_academic_year_id:)
    Placements::SupportUser.update_all(selected_academic_year_id:)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
