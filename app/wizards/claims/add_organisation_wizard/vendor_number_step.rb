class Claims::AddOrganisationWizard::VendorNumberStep < BaseStep
  attribute :vendor_number

  validates :vendor_number, presence: true
end
