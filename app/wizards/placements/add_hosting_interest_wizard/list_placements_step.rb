class Placements::AddHostingInterestWizard::ListPlacementsStep < BaseStep
  attribute :list_placements

  YES = "Yes".freeze
  NO = "No".freeze
  LIST_PLACEMENTS = [YES, NO].freeze

  validates :list_placements, presence: true, inclusion: { in: LIST_PLACEMENTS }

  def responses_for_selection
    [
      OpenStruct.new(name: YES),
      OpenStruct.new(name: NO),
    ]
  end
end
