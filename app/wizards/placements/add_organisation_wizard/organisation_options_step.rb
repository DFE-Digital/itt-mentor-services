class Placements::AddOrganisationWizard::OrganisationOptionsStep < Placements::AddOrganisationWizard::OrganisationSelectionStep
  attribute :search_param

  def id_presence
    return if id.present?

    errors.add(:id, :blank, organisation_type: wizard.organisation_type)
  end

  def organisations
    return if wizard.organisation_model.blank?

    @organisations ||= if wizard.steps[:organisation_type].provider?
                         wizard.organisation_model.search_name_urn_ukprn_postcode(
                           search_params.downcase,
                         )
                       else
                         wizard.organisation_model.search_name_urn_postcode(
                           search_params.downcase,
                         )
                       end.decorate
  end

  def search_params
    @search_params ||= search_param || @wizard.steps[:organisation].id
  end
end
