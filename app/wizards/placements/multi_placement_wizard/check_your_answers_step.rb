class Placements::MultiPlacementWizard::CheckYourAnswersStep < BaseStep
  delegate :phases, to: :phase_step
  delegate :year_groups, :selected_secondary_subjects, :selected_providers, to: :wizard

  private

  def phase_step
    wizard.steps.fetch(:phase)
  end
end
