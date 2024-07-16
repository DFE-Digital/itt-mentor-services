class Placements::AddPartnershipWizard::PartnershipStep < Placements::AddPartnershipWizard::PartnershipSelectionStep
  attribute :name

  def id_presence
    return if id.present?

    errors.add(:id, "#{partner_organisation_type}_blank".to_sym)
  end

  def autocomplete_path_value
    "/api/#{partner_organisation_type}_suggestions"
  end

  def autocomplete_return_attributes_value
    if partner_organisation_model == Provider
      %w[code]
    else
      %w[town postcode]
    end
  end
end
