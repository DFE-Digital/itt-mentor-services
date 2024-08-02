class Placements::AddPlacementWizard::PreviewPlacementStep < Placements::BaseStep
  delegate :build_placement, to: :wizard

  def placement
    @placement ||= build_placement
  end
end
