class Placements::AddPlacementWizard::YearGroupStep < Placements::BaseStep
  attribute :year_group, default: nil

  delegate :primary?, to: :school, prefix: true, allow_nil: true

  validates :year_group, presence: true, if: :school_primary?

  def year_groups_for_selection
    Placement.year_groups_as_options
  end

  def wizard_attributes
    { year_group: }
  end
end
