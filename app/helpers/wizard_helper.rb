module WizardHelper
  def render_wizard(wizard, **args)
    render wizard.step.to_partial_path, { wizard:, current_step: wizard.step }.merge(args)
  end
end
