class BackfillModernLanguagePlacementsWithAdditionalSubjects < ActiveRecord::Migration[7.1]
  def up
    return if modern_languages.blank?

    Placement.where(subject: modern_languages.child_subjects).find_each do |placement|
      additional_subject = placement.subject
      placement.update!(
        subject: modern_languages,
        additional_subjects: [additional_subject],
      )
    end
  end

  def down
    return if modern_languages.blank?

    additional_subjects = Placements::PlacementAdditionalSubject.where(
      subject: modern_languages.child_subjects,
    )
    additional_subjects.find_each do |additional_subject|
      additional_subject.placement.update!(subject: additional_subject.subject)
      additional_subject.destroy!
    end
  end

  private

  def modern_languages
    @modern_languages ||= Subject.find_by(name: "Modern Languages")
  end
end
