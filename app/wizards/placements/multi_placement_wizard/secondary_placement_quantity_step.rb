class Placements::MultiPlacementWizard::SecondaryPlacementQuantityStep < Placements::MultiPlacementWizard::PlacementQuantityStep
  delegate :selected_secondary_subjects, to: :wizard

  Subject.secondary.order_by_name.find_each do |subject|
    attribute subject.name_as_attribute
  end

  def subjects
    selected_secondary_subjects
  end
end
