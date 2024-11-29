class Claims::AddSchoolWizard::SchoolOptionsStep < Claims::AddSchoolWizard::SchoolSelectionStep
  attribute :search_param

  def id_presence
    return if id.present?

    errors.add(:id, :blank)
  end

  def schools
    @schools ||= ::School.search_name_urn_postcode(
      search_param.downcase,
    ).decorate
  end

  def search_param
    @wizard.steps[:school].id
  end
end
