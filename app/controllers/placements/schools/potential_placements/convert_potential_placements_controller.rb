class Placements::Schools::PotentialPlacements::ConvertPotentialPlacementsController < Placements::ApplicationController
  include WizardController

  attr_reader :school

  before_action :set_school
  before_action :set_wizard
  before_action :authorize_hosting_interest

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.convert_placements

      if @wizard.convert?
        @wizard.reset_state
        redirect_to placements_school_placements_path(@school),
                    flash: { heading: t(".success.heading"), body: t(".success.body_html") }
      else
        session["whats_next"] = @wizard.placements_information
        @wizard.reset_state

        redirect_to whats_next_placements_school_hosting_interests_path(@school)
      end
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::ConvertPotentialPlacementWizard.new(
      current_user:,
      school:,
      params:,
      state:,
      current_step:,
    )
  end

  def step_path(step)
    convert_potential_placements_placements_school_potential_placements_path(state_key:, step:)
  end

  def index_path
    placements_school_placements_path(@school)
  end

  def authorize_hosting_interest
    authorize @school, :edit_potential_placements?
  end
end
