class Placements::AddPartnershipWizard::PartnershipOptionsStep < Placements::AddPartnershipWizard::PartnershipSelectionStep
  def id_presence
    return if id.present?

    errors.add(:id, :blank, organisation_type: partner_organisation_type)
  end

  def partnership_options
    @partnership_options ||= if partner_organisation_model == Provider
                               partner_organisation_model.search_name_urn_ukprn_postcode(
                                 search_param.downcase,
                               )
                             else
                               partner_organisation_model.search_name_urn_postcode(
                                 search_param.downcase,
                               )
                             end.decorate
  end

  def search_param
    @wizard.steps[:partnership].id
  end
end
