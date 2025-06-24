class Placements::AddHostingInterestWizard::Interested::PlacementQuantityKnownStep < BaseStep
  attribute :quantity_known

  YES = "Yes".freeze
  NO = "No".freeze
  QUANTITY_KNOWN_OPTIONS = [YES, NO].freeze

  validates :quantity_known, presence: true, inclusion: { in: QUANTITY_KNOWN_OPTIONS }

  def options_for_selection
    QUANTITY_KNOWN_OPTIONS.map do |option|
      OpenStruct.new(
        name: I18n.t("#{locale_path}.#{option.downcase}"),
      )
    end
  end

  def is_quantity_known?
    quantity_known == YES
  end

  private

  def locale_path
    ".wizards.placements.add_hosting_interest_wizard.interested.placement_quantity_known_step.options"
  end
end
