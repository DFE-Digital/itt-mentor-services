class Placements::MultiPlacementWizard::SubjectsKnownStep < BaseStep
  attribute :subjects_known

  YES = "Yes".freeze
  NO = "No".freeze
  VALID_SUBJECTS_KNOWN = [YES, NO].freeze

  validates :subjects_known, presence: true, inclusion: VALID_SUBJECTS_KNOWN

  def responses_for_selection
    [
      OpenStruct.new(
        name: YES,
        hint: I18n.t(
          "#{locale_path}.options.yes.hint",
        ),
      ),
      OpenStruct.new(
        name: NO,
        hint: I18n.t(
          "#{locale_path}.options.no.hint",
        ),
      ),
    ]
  end

  private

  def locale_path
    ".wizards.placements.multi_placement_wizard.subjects_known_step"
  end
end
