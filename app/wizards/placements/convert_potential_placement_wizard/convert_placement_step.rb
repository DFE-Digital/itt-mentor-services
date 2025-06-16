class Placements::ConvertPotentialPlacementWizard::ConvertPlacementStep < BaseStep
  attribute :convert

  YES = "Yes".freeze
  NO = "No".freeze
  CONVERT_OPTIONS = [YES, NO].freeze

  validates :convert, presence: true, inclusion: { in: CONVERT_OPTIONS }

  def options_for_selection
    CONVERT_OPTIONS.map do |option|
      OpenStruct.new(
        value: option,
        name: I18n.t("#{locale_path}.#{option.downcase}"),
        hint: I18n.t("#{locale_path}.#{option.downcase}_hint"),
      )
    end
  end

  def convert?
    convert == YES
  end

  private

  def locale_path
    ".wizards.placements.convert_potential_placement_wizard.convert_placement_step.options"
  end
end
