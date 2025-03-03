class Placements::MultiPlacementWizard::SecondaryPlacementQuantityStep < Placements::MultiPlacementWizard::PlacementQuantityStep
  delegate :selected_secondary_subjects, to: :wizard

  def initialize(wizard:, attributes:)
    define_subject_attributes(
      selected_subjects: wizard.selected_secondary_subjects,
      attributes: attributes.presence || wizard.state["secondary_placement_quantity"],
    )

    super(wizard:, attributes:)
  end

  def subjects
    selected_secondary_subjects
  end
end
