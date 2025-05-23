class SetPlacementsSubjectToPrimary < ActiveRecord::Migration[7.2]
  def up
    other_primary_subjects = Subject.primary.where.not(id: Subject.primary_subject.id)

    Placement.where(subject_id: other_primary_subjects.select(:id)).update_all(subject_id: Subject.primary_subject.id)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
