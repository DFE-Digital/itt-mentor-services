class Placements::MultiPlacementWizard::PrimaryPlacementQuantityStep < Placements::MultiPlacementWizard::PlacementQuantityStep
  delegate :selected_primary_subjects, to: :wizard

  Subject.primary.order_by_name.find_each do |subject|
    attribute subject.name_as_attribute
  end

  def subjects
    selected_primary_subjects
  end
end
