class Placements::Schools::Placements::AddPlacementController < Placements::ApplicationController
  include WizardController

  before_action :set_school
  before_action :set_wizard
  before_action :authorize_placement

  helper_method :step_path, :current_step_path, :back_link_path, :add_mentor_path

  attr_reader :school

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      placement = @wizard.create_placement
      Placements::PlacementSlackNotifier.placement_created_notification(@school, placement.decorate).deliver_later
      @wizard.reset_state
      redirect_to after_create_placement_path(@school), flash: {
        heading: t("wizards.placements.add_placement_wizard.update.success_heading"),
      }
    end
  end

  private

  def after_create_placement_path(school)
    placements_school_placements_path(school)
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::AddPlacementWizard.new(school:, params:, state:, current_step:)
  end

  def authorize_placement
    authorize school.placements.build, :add_placement_journey?
  end

  def step_path(step)
    add_placement_placements_school_placements_path(state_key:, step:)
  end

  def index_path
    placements_school_placements_path(@school)
  end

  def add_mentor_path
    new_add_mentor_placements_school_mentors_path
  end
end
