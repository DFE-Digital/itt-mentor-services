class BackfillPlacementsWithSubject < ActiveRecord::Migration[7.1]
  def up
    Placement.where(subject_id: nil).find_each do |placement|
      placement.update!(subject: placement.subjects.last)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
