class Placements::AddPlacement::Steps::Phase
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :school
  attribute :phase

  validates :school, presence: true
  validates :phase, presence: true
  validate :phase_is_valid

  def phases_for_selection
    { primary: "Primary", secondary: "Secondary" }
  end

  def wizard_attributes
    { phase: }
  end

  private

  def phase_is_valid
    return if [Placements::School::PRIMARY_PHASE, Placements::School::SECONDARY_PHASE].include?(phase)

    errors.add(:phase, :invalid)
  end
end
