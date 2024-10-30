class Placements::AddPlacementWizard::PreviewPlacementStep < BaseStep
  delegate :build_placement, to: :wizard

  def placement
    @placement ||= build_placement
  end
end
