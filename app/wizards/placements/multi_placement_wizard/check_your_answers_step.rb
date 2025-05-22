class Placements::MultiPlacementWizard::CheckYourAnswersStep < BaseStep
  delegate :phases, to: :phase_step
  delegate :year_groups, :selected_secondary_subjects, :selected_providers,
           :sen_quantity, :selected_key_stages, to: :wizard

  private

  def phase_step
    wizard.steps.fetch(:phase)
  end
end
