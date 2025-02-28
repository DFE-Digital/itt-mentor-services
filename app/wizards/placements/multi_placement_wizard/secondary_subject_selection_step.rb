class Placements::MultiPlacementWizard::SecondarySubjectSelectionStep < Placements::MultiPlacementWizard::SubjectSelectionStep
  private

  def phase
    Placements::School::SECONDARY_PHASE
  end
end
