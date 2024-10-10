module Placements
  class AddPartnershipWizard < BaseWizard
    attr_reader :organisation

    def initialize(organisation:, params:, state:, current_step: nil)
      @organisation = organisation
      super(state:, params:, current_step:)
    end

    def define_steps
      add_step(PartnershipStep)
      add_step(PartnershipOptionsStep) if steps[:partnership].partner_organisation.blank?
      add_step(CheckYourAnswersStep)
    end

    def partner_organisation
      @partner_organisation ||= (steps[:partnership_options]&.partner_organisation ||
          steps[:partnership].partner_organisation).decorate
    end

    def create_partnership
      raise "Invalid wizard state" unless valid?

      if organisation.respond_to?(:partner_schools)
        organisation.partner_schools << partner_organisation
      else
        organisation.partner_providers << partner_organisation
      end
      organisation.save!
    end

    def partner_organisation_type
      @partner_organisation_type ||= partner_organisation_model.to_s.downcase
    end

    def partner_organisation_model
      @partner_organisation_model ||= {
        School => ::Provider,
        Provider => ::School,
      }.fetch(organisation.class)
    end
  end
end
