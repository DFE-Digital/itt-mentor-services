class Placements::AddPlacementWizard::PrimarySubjectSelectionStep < Placements::AddPlacementWizard::SubjectSelectionStep
  private

  def phase
    Placements::School::PRIMARY_PHASE
  end
end
