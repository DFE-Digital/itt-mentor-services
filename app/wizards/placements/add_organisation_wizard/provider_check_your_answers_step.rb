class Placements::AddOrganisationWizard::ProviderCheckYourAnswersStep < Placements::AddOrganisationWizard::BaseStep
  def provider
    @provider ||= (wizard.steps[:provider_options]&.provider ||
        wizard.steps[:provider].provider).decorate
  end
end
