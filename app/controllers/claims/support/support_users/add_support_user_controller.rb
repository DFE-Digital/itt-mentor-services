class Claims::Support::SupportUsers::AddSupportUserController < Claims::Support::ApplicationController
  include WizardController

  before_action :set_wizard
  before_action :authorize_support_user

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      support_user = @wizard.create_support_user
      SupportUser::Invite.call(support_user:)
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
    @wizard = Claims::AddSupportUserWizard.new(params:, state:, current_step:)
  end

  def step_path(step)
    add_support_user_claims_support_support_users_path(state_key:, step:)
  end

  def index_path
    claims_support_support_users_path
  end

  def authorize_support_user
    authorize Claims::SupportUser
  end
end
