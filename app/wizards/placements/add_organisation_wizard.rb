module Placements
  class AddOrganisationWizard < BaseWizard
    def define_steps
      add_step(OrganisationTypeStep)
      add_step(OrganisationStep)
      add_step(OrganisationOptionsStep) if steps.fetch(:organisation).organisation.blank?
      add_step(CheckYourAnswersStep)
    end

    def organisation_type
      steps.fetch(:organisation_type).organisation_type
    end

    def organisation_model
      {
        OrganisationTypeStep::PROVIDER => ::Provider,
        OrganisationTypeStep::SCHOOL => ::School,
      }[organisation_type]
    end

    def organisation
      @organisation ||= (steps[:organisation_options]&.organisation ||
          steps.fetch(:organisation).organisation).decorate
    end

    def onboard_organisation
      organisation.update!(placements_service: true)
    end
  end
end
