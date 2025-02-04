class Placements::AddPartnershipWizard::PartnershipSelectionStep < BaseStep
  attribute :id

  validate :id_presence
  validate :new_partnership

  delegate :partner_organisation_model, :partner_organisation_type, to: :wizard

  def new_partnership
    existing_partnership = if partner_organisation.is_a?(School)
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

    return if existing_partnership.blank?

    errors.add(
      :id,
      :already_added,
      organisation_name: partner_organisation.name,
      organisation_type: partner_organisation_type,
    )
  end

  def partner_organisation_name
    @partner_organisation_name ||= partner_organisation&.name
  end

  def partner_organisation
    @partner_organisation ||= partner_organisation_model.find_by(id:)
  end

  def scope
    wizard_name = class_to_path(wizard.class)
    step_name = class_to_path(self.class)
    "placements_#{wizard_name}_#{step_name}"
  end

  private

  def class_to_path(klass)
    klass.name.demodulize.underscore
  end
end
