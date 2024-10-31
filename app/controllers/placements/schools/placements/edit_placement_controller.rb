class Placements::Schools::Placements::EditPlacementController < Placements::ApplicationController
  include WizardController

  before_action :set_school
  before_action :set_placement
  before_action :set_wizard
  before_action :authorize_placement

  helper_method :add_mentor_path, :unlisted_provider_path

  attr_reader :school

  def new
    @wizard.setup_state
    redirect_to step_path(@wizard.first_step)
  end

  def update
    if !@wizard.save_step
      render "edit"
    else
      @wizard.update_placement
      notify_provider(@wizard.placement) if @wizard.placement.saved_change_to_provider_id?
      @wizard.reset_state
      redirect_to after_update_placement_path, flash: {
        heading: t(".success.#{params[:step]}"),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params.fetch(:step).to_sym
    @wizard = Placements::EditPlacementWizard.new(school:, placement: @placement, state:, params:, current_step:)
  end

  def authorize_placement
    authorize school.placements.build, :add_placement_journey?
  end

  def after_update_placement_path
    placements_school_placement_path(@school, @placement)
  end

  def step_path(step)
    edit_placement_placements_school_placement_path(state_key:, step:)
  end

  def index_path
    placements_school_placement_path(@school, @placement)
  end

  def set_placement
    @placement = school.placements.find(params.require(:id))
  end

  def add_mentor_path
    new_add_mentor_placements_school_mentors_path
  end

  def unlisted_provider_path
    placements_school_partner_providers_path(@school)
  end

  def notify_provider(placement)
    from_provider_id = @wizard.placement.saved_change_to_provider_id.first
    to_provider_id = @wizard.placement.saved_change_to_provider_id.last

    if from_provider_id.present?
      Placements::Placements::NotifyProvider::Remove.call(
        provider: Provider.find(from_provider_id),
        placement:,
      )
    end

    if to_provider_id.present?
      Placements::Placements::NotifyProvider::Assign.call(
        provider: Provider.find(to_provider_id),
        placement:,
      )
    end
  end
end
