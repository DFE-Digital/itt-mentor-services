class Placements::Schools::Placements::AddMultiplePlacementsController < Placements::ApplicationController
  include WizardController

  before_action :set_school
  before_action :set_wizard
  before_action :authorize_placement

  attr_reader :school

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.update_school_placements
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success"),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::MultiPlacementWizard.new(school:, params:, state:, current_step:)
  end

  def authorize_placement
    authorize school.placements.build, :add_placement_journey?
  end

  def step_path(step)
    add_multiple_placements_placements_school_placements_path(state_key:, step:)
  end

  def index_path
    placements_school_placements_path(@school)
  end
end
