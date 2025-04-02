class Placements::MultiPlacementWizard::ConfirmStep < BaseStep
  delegate :first_name, :last_name, :email_address, to: :school_contact_step, prefix: :school_contact

  private

  def school_contact_step
    wizard.steps.fetch(:school_contact)
  end
end
