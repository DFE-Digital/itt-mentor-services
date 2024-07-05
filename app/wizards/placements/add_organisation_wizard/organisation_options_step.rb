class Placements::AddOrganisationWizard::OrganisationOptionsStep < Placements::AddOrganisationWizard::OrganisationSelectionStep
  attribute :search_param

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
                       end.map(&:decorate)
  end

  def search_params
    @search_params ||= search_param || @wizard.steps[:organisation].id
  end
end
