class Placements::AddPlacementWizard::YearGroupStep < BaseStep
  attribute :year_group, default: nil

  validates :year_group, presence: true

  def year_groups_for_selection
    year_groups_as_options
      .reject { |option| option.value == "mixed_year_groups" }
  end

  def mixed_year_group_option
    @mixed_year_group_option ||= year_groups_as_options
        .find { |option| option.value == "mixed_year_groups" }
  end

  private

  def year_groups_as_options
    @year_groups_as_options ||= Placement.year_groups_as_options
  end
end
