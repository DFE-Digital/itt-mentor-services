module Placements
  class AddOrganisationWizard < BaseWizard
    def define_steps
      add_step(OrganisationTypeStep)
      add_step(OrganisationStep)
      add_step(OrganisationOptionsStep) if steps[:organisation].organisation.blank?
      add_step(CheckYourAnswersStep)
    end

    def organisation_type
      steps[:organisation_type].organisation_type
    end

    def organisation_model
      return if organisation_type.blank?

      organisation_type.camelize.constantize
    end

    def organisation
      steps[:check_your_answers].organisation
    end

    def onboard_organisation
      organisation.update!(placements_service: true)
    end
  end
end
