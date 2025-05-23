class Placements::Schools::PotentialPlacements::EditPotentialPlacementsController < Placements::ApplicationController
  include WizardController

  attr_reader :school

  before_action :set_school
  before_action :set_wizard
  before_action :authorize_hosting_interest

  def new
    @wizard.setup_state
    redirect_to step_path(@wizard.first_step)
  end

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.update_potential_placements
      school.reload
      @wizard.reset_state
      redirect_to whats_next_placements_school_hosting_interests_path(@school)
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::EditPotentialPlacementsWizard.new(
      school:,
      params:,
      state:,
      current_step:,
    )
  end

  def step_path(step)
    edit_potential_placements_placements_school_potential_placements_path(state_key:, step:)
  end

  def index_path
    placements_school_placements_path(@school)
  end

  def authorize_hosting_interest
    authorize @school, :edit_potential_placements?
  end
end
