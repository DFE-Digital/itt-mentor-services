class Claims::AddExceptionalClaimWizard::SchoolStep < Claims::AddExceptionalClaimWizard::SchoolSelectionStep
  attribute :name

  delegate :school_name, to: :wizard

  def autocomplete_path_value
    "/api/school_suggestions"
  end

  def autocomplete_return_attributes_value
    %w[town postcode]
  end
end
