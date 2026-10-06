class Claims::AddExceptionalClaimWizard::SchoolOptionsStep < Claims::AddExceptionalClaimWizard::SchoolSelectionStep
  attribute :search_param

  def schools
    @schools ||= ::School
      .search_name_urn_postcode(search_param.downcase)
      .decorate
  end

  def search_param
    @wizard.steps[:school].id
  end
end
