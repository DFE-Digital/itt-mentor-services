class Placements::AddPartnershipWizard::PartnershipSelectionStep < Placements::BaseStep
  attribute :id

  validate :id_presence
  validate :new_partnership

  def partner_organisation_name
    @partner_organisation_name ||= partner_organisation&.name
  end

  def new_partnership
    existing_placement = if partner_organisation.is_a?(School)
                           Placements::Partnership.find_by(
                             provider: wizard.organisation,
                             school: partner_organisation,
                           )
                         else
                           Placements::Partnership.find_by(
                             provider: partner_organisation,
                             school: wizard.organisation,
                           )
                         end

    return if existing_placement.blank?

    errors.add(
      :id,
      :already_added,
      organisation_name: partner_organisation.name,
      organisation_type: partner_organisation_type,
    )
  end

  def partner_organisation
    @partner_organisation ||= partner_organisation_model&.find_by(id:)
  end

  def scope
    wizard_name = class_to_path(wizard.class)
    step_name = class_to_path(self.class)
    "placements_#{wizard_name}_#{step_name}"
  end

  def partner_organisation_model
    @partner_organisation_model ||= {
      Placements::School => Provider,
      Placements::Provider => School,
    }[wizard.organisation.class]
  end

  def partner_organisation_type
    @partner_organisation_type ||= partner_organisation_model.to_s.downcase
  end
end
