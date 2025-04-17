class Claims::AddOrganisationWizard::NameStep < BaseStep
  attribute :name

  validates :name, presence: true
end
