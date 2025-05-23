class SetPlacementsSubjectToPrimary < ActiveRecord::Migration[7.2]
  def up
    primary_subject = Subject.find_by(name: "Primary", subject_area: "primary")
    unless primary_subject
      raise ActiveRecord::IrreversibleMigration, "No subject found with name 'Primary' and subject_area 'primary'"
    end

    other_primary_subjects = Subject.where(subject_area: "primary").where.not(id: primary_subject.id)

    Placement.where(subject_id: other_primary_subjects.pluck(:id)).update_all(subject_id: primary_subject.id)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
