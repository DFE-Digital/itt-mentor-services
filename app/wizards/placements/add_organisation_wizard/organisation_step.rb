class Placements::AddOrganisationWizard::OrganisationStep < Placements::AddOrganisationWizard::OrganisationSelectionStep
  attribute :name

  def autocomplete_path_value
    "/api/#{wizard.organisation_type}_suggestions"
  end

  def autocomplete_return_attributes_value
    if wizard.steps[:organisation_type].provider?
      %w[code]
    else
      %w[town postcode]
    end
  end
end
