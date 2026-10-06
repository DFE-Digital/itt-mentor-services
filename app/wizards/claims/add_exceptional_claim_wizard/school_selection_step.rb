class Claims::AddExceptionalClaimWizard::SchoolSelectionStep < BaseStep
  attribute :id

  validates :id, presence: true

  def school
    @school ||= ::School.find_by(id:)&.becomes(Claims::School)
  end

  def scope
    self.class.name.underscore.parameterize(separator: "_")
  end
end
