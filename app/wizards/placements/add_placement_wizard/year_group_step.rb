class Placements::AddPlacementWizard::YearGroupStep < Placements::BaseStep
  attribute :year_group, default: nil

  validates :year_group, presence: true

  def year_groups_for_selection
    Placement.year_groups_as_options
  end
end
