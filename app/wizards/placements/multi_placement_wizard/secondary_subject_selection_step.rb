class Placements::MultiPlacementWizard::SecondarySubjectSelectionStep < Placements::MultiPlacementWizard::SubjectSelectionStep
  delegate :stem_subjects, :lit_lang_subjects,
           :art_humanities_social_subjects, :health_physical_education_subjects,
           to: :subjects_for_selection

  private

  def phase
    Placements::School::SECONDARY_PHASE
  end
end
