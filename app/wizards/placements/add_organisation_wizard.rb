module Placements
  class AddOrganisationWizard < BaseWizard
    attr_reader :current_user

    def initialize(current_user:, params:, state:, current_step: nil)
      @current_user = current_user
      super(state:, params:, current_step:)
    end

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
      if organisation.instance_of?(::School)
        organisation.update!(placements_service: true, manually_onboarded_by: current_user)
      else
        organisation.update!(placements_service: true)
      end
    end

    delegate :support_user?, to: :current_user
  end
end
