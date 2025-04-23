class Placements::AddHostingInterestWizard::Interested::PhaseStep < Placements::MultiPlacementWizard::PhaseStep
  def unknown_option
    OpenStruct.new(
      name: I18n.t(
        ".wizards.placements.add_hosting_interest_wizard.phase_step.options.unknown",
      ),
      description: I18n.t(
        ".wizards.placements.add_hosting_interest_wizard.phase_step.options.unknown_description",
      ),
    )
  end
end
