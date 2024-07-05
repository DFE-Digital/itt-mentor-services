class Placements::AddOrganisationWizard::OrganisationStep < Placements::AddOrganisationWizard::OrganisationSelectionStep
  attribute :name

  def id_presence
    return if id.present?

    errors.add(:id, "#{wizard.organisation_type}_blank".to_sym)
  end

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
