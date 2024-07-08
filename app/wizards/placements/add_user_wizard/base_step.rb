class Placements::AddUserWizard::BaseStep < Placements::BaseStep
  # Remove this once https://github.com/DFE-Digital/itt-mentor-services/pull/820/files merged

  def to_partial_path
    wizard_name = class_to_path(wizard.class)
    step_name = class_to_path(self.class)
    "placements/wizards/#{wizard_name}/#{step_name}"
  end

  private

  def class_to_path(klass)
    klass.name.demodulize.underscore
  end

  ########
end

