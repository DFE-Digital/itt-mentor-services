class Placements::Support::Organisations::AddOrganisationController < Placements::ApplicationController
  include WizardController

  before_action :set_wizard

  helper_method :step_path

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.onboard_organisation
      @wizard.reset_state
      redirect_to placements_support_organisations_path, flash: {
        heading: t(".success_heading"),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::AddOrganisationWizard.new(params:, state:, current_step:)
  end

  def step_path(step)
    add_organisation_placements_support_organisations_path(state_key:, step:)
  end

  def index_path
    placements_support_organisations_path
  end
end
