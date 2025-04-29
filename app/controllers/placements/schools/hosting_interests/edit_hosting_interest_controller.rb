class Placements::Schools::HostingInterests::EditHostingInterestController < Placements::ApplicationController
  include WizardController

  attr_reader :school, :hosting_interest

  before_action :set_school
  before_action :set_hosting_interest
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
      @wizard.update_hosting_interest
      school.reload
      if appetite == "actively_looking"
        session["whats_next"] = @wizard.placements_information
      end
      @wizard.reset_state

      flash_locales_path = "placements.schools.hosting_interests.add_hosting_interest.update"
      redirect_to whats_next_placements_school_hosting_interests_path(@school), flash: {
        heading: t("#{flash_locales_path}.heading.#{appetite}"),
        body: t("#{flash_locales_path}.body.#{appetite}_html"),
      }
    end
  end

  private

  def set_hosting_interest
    @hosting_interest = Placements::HostingInterest.find(params[:id])
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::EditHostingInterestWizard.new(
      hosting_interest:,
      school:,
      params:,
      state:,
      current_step:,
    )
  end

  def step_path(step)
    edit_hosting_interest_placements_school_hosting_interest_path(state_key:, step:)
  end

  def index_path
    placements_school_placements_path(@school)
  end

  def appetite
    @hosting_interest.reload.appetite
  end

  def authorize_hosting_interest
    authorize @hosting_interest, :edit?
  end
end
