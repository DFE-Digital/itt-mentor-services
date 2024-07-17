module Placements
  class AddPartnershipWizard < BaseWizard
    attr_reader :organisation, :partner_organisation_model

    def initialize(organisation:, params:, session:, current_step: nil)
      @organisation = organisation
      @partner_organisation_model = partner_org_model
      super(session:, params:, current_step:)
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

      if partner_organisation_model == (::School)
        Partnership.create!(school: partner_organisation, provider: organisation)
      else
        Partnership.create!(school: organisation, provider: partner_organisation)
      end
    end

    def partner_organisation_type
      @partner_organisation_type ||= partner_organisation_model.to_s.downcase
    end

    private

    def partner_org_model
      {
        School => ::Provider,
        Provider => ::School,
      }[organisation.class]
    end
  end
end
