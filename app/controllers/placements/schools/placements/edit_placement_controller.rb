class Placements::Schools::Placements::EditPlacementController < Placements::ApplicationController
  before_action :set_school
  before_action :set_placement
  before_action :set_wizard
  before_action :authorize_placement

  helper_method :step_path, :current_step_path, :back_link_path, :add_mentor_path, :unlisted_provider_path

  attr_reader :school

  def new
    @wizard.reset_state
    @wizard.setup_state
    redirect_to step_path(@wizard.first_step)
  end

  def edit; end

  def update
    if !@wizard.save_step
      render "edit"
    else
      @wizard.update_placement
      Placements::PlacementSlackNotifier.placement_created_notification(@school, @placement.decorate).deliver_later
      @wizard.reset_state
      redirect_to after_update_placement_path, flash: { success: t(".success", step_attribute: params[:step].titleize) }
    end
  end

  private

  def set_school
    school_id = params.require(:school_id)
    @school = current_user.schools.find(school_id)
  end

  def set_wizard
    current_step = params.fetch(:step).to_sym
    @wizard = Placements::EditPlacementWizard.new(school:, placement: @placement, session:, params:, current_step:)
  end

  def authorize_placement
    authorize school.placements.build, :add_placement_journey?
  end

  def after_update_placement_path
    placements_school_placement_path(@school, @placement)
  end

  def step_path(step)
    edit_placement_placements_school_placement_path(step:)
  end

  def current_step_path
    step_path(@wizard.current_step)
  end

  def back_link_path
    placements_school_placement_path(@school, @placement)
  end

  def set_placement
    @placement = school.placements.find(params.require(:id))
  end

  def add_mentor_path
    new_placements_school_mentor_path
  end

  def unlisted_provider_path
    placements_school_partner_providers_path(@school)
  end
end
