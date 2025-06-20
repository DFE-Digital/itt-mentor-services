class Placements::AddHostingInterestWizard::CheckYourAnswersStep < BaseStep
  delegate :phases, to: :phase_step
  delegate :year_groups, :selected_secondary_subjects, :selected_providers, :selected_key_stages, to: :wizard
  delegate :first_name, :last_name, :email_address, to: :school_contact_step, prefix: :school_contact

  private

  def phase_step
    wizard.steps.fetch(:phase)
  end

  def school_contact_step
    wizard.steps.fetch(:school_contact)
  end
end
