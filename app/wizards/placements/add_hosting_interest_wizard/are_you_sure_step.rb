class Placements::AddHostingInterestWizard::AreYouSureStep < BaseStep
  delegate :first_name, :last_name, :email_address, to: :school_contact_step, prefix: :school_contact
  delegate :reasons_not_hosting, :other_reason_not_hosting, to: :reason_not_hosting_step

  private

  def school_contact_step
    wizard.steps.fetch(:school_contact)
  end

  def reason_not_hosting_step
    wizard.steps.fetch(:reason_not_hosting)
  end
end
