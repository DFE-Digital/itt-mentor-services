class Placements::AddPartnershipWizard::PartnershipOptionsStep < Placements::AddPartnershipWizard::PartnershipSelectionStep
  attribute :search_param

  def id_presence
    return if id.present?

    errors.add(:id, :blank, organisation_type: partner_organisation_type)
  end

  def partnership_options
    @partnership_options ||= if partner_organisation_model == Provider
                               partner_organisation_model.search_name_urn_ukprn_postcode(
                                 search_params.downcase,
                               )
                             else
                               partner_organisation_model.search_name_urn_postcode(
                                 search_params.downcase,
                               )
                             end.decorate
  end

  def search_params
    @search_params ||= search_param || @wizard.steps[:partnership].id
  end
end
