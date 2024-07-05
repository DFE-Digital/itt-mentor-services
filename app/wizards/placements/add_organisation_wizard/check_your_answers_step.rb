class Placements::AddOrganisationWizard::CheckYourAnswersStep < Placements::AddOrganisationWizard::BaseStep
  def organisation
    @organisation ||= (wizard.steps[:organisation_options]&.organisation ||
        wizard.steps[:organisation].organisation).decorate
  end
end
