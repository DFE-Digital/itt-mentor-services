module Placements
  class AddOrganisationWizard < BaseWizard
    def define_steps
      add_step(OrganisationTypeStep)
      if steps[:organisation_type].provider?
        add_step(ProviderStep)
        add_step(ProviderOptionsStep) if steps[:provider].provider.blank?
        add_step(ProviderCheckYourAnswersStep)
      else
        add_step(SchoolStep)
        add_step(SchoolOptionsStep) if steps[:school].present?
        add_step(SchoolCheckYourAnswersStep)
      end
    end

    def provider
      steps[:provider_check_your_answers].provider
    end

    def onboard_provider
      provider.update!(placements_service: true)
    end
  end
end
