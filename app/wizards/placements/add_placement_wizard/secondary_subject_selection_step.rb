class Placements::AddPlacementWizard::SecondarySubjectSelectionStep < Placements::AddPlacementWizard::SubjectSelectionStep
  delegate :stem_subjects, :lit_lang_subjects,
           :art_humanities_social_subjects, :health_physical_education_subjects,
           to: :subjects_for_selection

  def subjects_for_selection
    @subjects_for_selection = Subject.parent_subjects.secondary
  end
end
