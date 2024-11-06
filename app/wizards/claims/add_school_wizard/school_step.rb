class Claims::AddSchoolWizard::SchoolStep < Claims::AddSchoolWizard::SchoolSelectionStep
  attribute :name

  def id_presence
    return if id.present?

    errors.add(:id, :school_blank)
  end

  def autocomplete_path_value
    "/api/school_suggestions"
  end

  def autocomplete_return_attributes_value
    %w[town postcode]
  end
end
