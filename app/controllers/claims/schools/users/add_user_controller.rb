class Claims::Schools::Users::AddUserController < Claims::ApplicationController
  include WizardController
  include Claims::BelongsToSchool

  before_action :has_school_accepted_grant_conditions?
  before_action :set_wizard
  before_action :authorize_user

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      user = @wizard.create_user
      User::Invite.call(user:, organisation: @school)
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
    @wizard = Claims::AddUserWizard.new(organisation: @school, params:, state:, current_step:)
  end

  def authorize_user
    authorize Claims::User
  end

  def step_path(step)
    add_user_claims_school_users_path(state_key:, step:)
  end

  def index_path
    claims_school_users_path(@school)
  end
end
