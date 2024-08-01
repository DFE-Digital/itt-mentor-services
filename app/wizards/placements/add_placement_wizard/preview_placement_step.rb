class Placements::AddPlacementWizard::PreviewPlacementStep < Placements::BaseStep
  delegate :build_placement, to: :wizard

  alias_method :placement, :build_placement
end
