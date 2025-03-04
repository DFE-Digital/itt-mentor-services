class Placements::MultiPlacementWizard::PrimaryPlacementQuantityStep < Placements::MultiPlacementWizard::PlacementQuantityStep
  delegate :selected_primary_subjects, to: :wizard

  def initialize(wizard:, attributes:)
    define_subject_attributes(
      selected_subjects: wizard.selected_primary_subjects,
      attributes:,
    )

    super(wizard:, attributes:)
  end

  def subjects
    selected_primary_subjects
  end
end
