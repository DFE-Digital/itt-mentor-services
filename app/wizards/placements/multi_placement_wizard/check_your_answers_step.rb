class Placements::MultiPlacementWizard::CheckYourAnswersStep < BaseStep
  delegate :phases, to: :phase_step
  delegate :selected_primary_subjects, :selected_secondary_subjects, :selected_providers, to: :wizard
  delegate :first_name, :last_name, :email_address, to: :school_contact_step, prefix: :school_contact

  def primary_and_secondary_phases?
    @primary_and_secondary_phases ||= phase_step.class::VALID_PHASES.sort == phases.sort
  end

  private

  def phase_step
    wizard.steps.fetch(:phase)
  end

  def school_contact_step
    wizard.steps.fetch(:school_contact)
  end
end
