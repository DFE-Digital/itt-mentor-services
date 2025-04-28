class Placements::MultiPlacementWizard::YearGroupSelectionStep < BaseStep
  attribute :year_groups, default: []

  validates :year_groups, presence: true

  def year_groups_for_selection
    year_groups_as_options
      .reject { |option| option.value == "mixed_year_groups" }
  end

  def mixed_year_group_option
    @mixed_year_group_option ||= year_groups_as_options
        .find { |option| option.value == "mixed_year_groups" }
  end

  def year_groups=(value)
    super normalised_year_groups(value)
  end

  private

  def year_groups_as_options
    @year_groups_as_options ||= Placement.year_groups_as_options
  end

  def normalised_year_groups(selected_year_groups)
    return [] if selected_year_groups.blank?

    selected_year_groups.reject(&:blank?)
  end
end
