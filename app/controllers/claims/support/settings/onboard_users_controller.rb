class Claims::Support::Settings::OnboardUsersController < Claims::Support::ApplicationController
  include WizardController

  before_action :has_school_accepted_grant_conditions?
  before_action :set_wizard
  before_action :authorize_user

  helper_method :index_path

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.upload_users
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success"),
        body: t(".body"),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::OnboardUsersWizard.new(params:, state:, current_step:)
  end

  def authorize_user
    authorize Claims::User, :new?
  end

  def step_path(step)
    onboard_users_claims_support_schools_path(state_key:, step:)
  end

  def index_path
    claims_support_settings_path
  end
end
