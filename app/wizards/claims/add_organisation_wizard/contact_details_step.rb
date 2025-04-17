class Claims::AddOrganisationWizard::ContactDetailsStep < BaseStep
  attribute :telephone
  attribute :website

  validates :telephone, presence: true, format: { with: /\A[0-9 ]+\z/, message: "only allows numbers and spaces" }
  validates :website, presence: true
end
