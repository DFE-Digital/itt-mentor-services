class Placements::EditHostingInterestWizard::ChangePlacementAvailabilityStep < BaseStep
  delegate :school, :current_user, :available_placements, to: :wizard

  def placements
    @placements ||= available_placements.decorate
  end
end
