class Placements::MultiPlacementWizard::SENPlacementQuantityStep < BaseStep
  attribute :sen_quantity

  validates(
    :sen_quantity,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 },
  )
end
