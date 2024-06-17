class Placements::AddPlacement::Steps::YearGroup
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :school
  attribute :year_group, default: nil

  delegate :primary?, to: :school, prefix: true, allow_nil: true

  validates :school, presence: true
  validates :year_group, presence: true, if: :school_primary?

  def year_groups_for_selection
    Placement.year_groups_as_options
  end

  def wizard_attributes
    { year_group: }
  end
end
