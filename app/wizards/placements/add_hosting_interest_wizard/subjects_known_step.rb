class Placements::AddHostingInterestWizard::SubjectsKnownStep < BaseStep
  attribute :subjects_known

  YES = "Yes".freeze
  NO = "No".freeze
  VALID_SUBJECTS_KNOWN = [YES, NO].freeze

  validates :subjects_known, presence: true, inclusion: VALID_SUBJECTS_KNOWN

  def responses_for_selection
    [
      OpenStruct.new(name: YES),
      OpenStruct.new(name: NO),
    ]
  end
end
