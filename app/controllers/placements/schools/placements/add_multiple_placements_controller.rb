class Placements::Schools::Placements::AddMultiplePlacementsController < Placements::ApplicationController
  include WizardController

  before_action :set_school
  before_action :set_wizard

  attr_reader :school

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.update_school_placements
      notify_user(@wizard.created_placements)
      session["whats_next"] = @wizard.placements_information
      @wizard.reset_state

      redirect_to whats_next_placements_school_hosting_interests_path(@school)
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::MultiPlacementWizard.new(
      current_user:,
      school:,
      params:,
      state:,
      current_step:,
    )
  end

  def step_path(step)
    add_multiple_placements_placements_school_placements_path(state_key:, step:)
  end

  def index_path
    placements_school_placements_path(@school)
  end

  def notify_user(placements)
    Placements::Placements::NotifySchool::CreatePlacements.call(
      user: current_user,
      school: @school,
      placements: placements,
      academic_year: current_user.selected_academic_year,
    )
  end
end
