class Placements::AddHostingInterestWizard::Interested::SecondaryChildSubjectPlacementSelectionStep < Placements::MultiPlacementWizard::SecondaryChildSubjectPlacementSelectionStep
  def unknown_option
    @unknown_option ||=
      OpenStruct.new(
        value: Placements::AddHostingInterestWizard::UNKNOWN_OPTION,
        name: I18n.t(
          "#{unknown_option_locale_path}.unknown",
        ),
      )
  end

  private

  def unknown_option_locale_path
    ".wizards.placements.add_hosting_interest_wizard.interested.secondary_child_subject_placement_selection_step.options"
  end
end
