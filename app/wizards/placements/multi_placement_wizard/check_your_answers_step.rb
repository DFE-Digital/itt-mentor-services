class Placements::MultiPlacementWizard::CheckYourAnswersStep < BaseStep
  delegate :phases, to: :phase_step
  delegate :selected_primary_subjects, :selected_secondary_subjects, :selected_providers, to: :wizard

  def primary_and_secondary_phases?
    @primary_and_secondary_phases ||= phase_step.class::VALID_PHASES.sort == phases.sort
  end

  private

  def phase_step
    wizard.steps.fetch(:phase)
  end
end
