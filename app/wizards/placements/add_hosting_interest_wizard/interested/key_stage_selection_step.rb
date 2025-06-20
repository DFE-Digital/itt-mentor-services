class Placements::AddHostingInterestWizard::Interested::KeyStageSelectionStep < Placements::MultiPlacementWizard::KeyStageSelectionStep
  def unknown_option
    @unknown_option ||=
      OpenStruct.new(
        value: Placements::AddHostingInterestWizard::UNKNOWN_OPTION,
        name: I18n.t(
          "#{unknown_option_locale_path}.unknown",
        ),
        description: I18n.t(
          "#{unknown_option_locale_path}.unknown_description",
        ),
      )
  end

  private

  def unknown_option_locale_path
    ".wizards.placements.add_hosting_interest_wizard.interested.key_stage_selection_step.options"
  end
end
