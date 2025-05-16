class Placements::AddPlacementWizard::PrimarySubjectSelectionStep < Placements::AddPlacementWizard::SubjectSelectionStep
  def subjects_for_selection
    @subjects_for_selection = Subject.parent_subjects.primary
  end
end
