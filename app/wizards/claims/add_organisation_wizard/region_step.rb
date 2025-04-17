class Claims::AddOrganisationWizard::RegionStep < BaseStep
  attribute :region_id

  validates :region_id, presence: true

  def regions
    @regions ||= Region.all
  end
end
