class Placements::MultiPlacementWizard::SecondaryPlacementQuantityStep < Placements::MultiPlacementWizard::PlacementQuantityStep
  delegate :selected_secondary_subjects, to: :wizard

  def initialize(wizard:, attributes:)
    define_subject_attributes(
      selected_subjects: wizard.selected_secondary_subjects,
      attributes: attributes,
    )

    super(
      wizard:,
      attributes: attributes&.select do |k, _v|
        wizard.selected_secondary_subjects
        .map(&:name_as_attribute)
        .include?(k)
      end
    )
  end

  def subjects
    selected_secondary_subjects
  end
end
