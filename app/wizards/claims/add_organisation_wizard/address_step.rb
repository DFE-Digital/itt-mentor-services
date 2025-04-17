class Claims::AddOrganisationWizard::AddressStep < BaseStep
  attribute :address1
  attribute :address2
  attribute :town
  attribute :postcode

  validates :address1, presence: true
  validates :town, presence: true
  validates :postcode, presence: true, format: { with: /\A[a-zA-Z0-9 ]+\z/, message: "only allows letters and numbers" }
end
