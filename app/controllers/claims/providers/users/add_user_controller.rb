class Claims::Providers::Users::AddUserController < Claims::Providers::ApplicationController
  include WizardController

  before_action :set_provider
  before_action :set_wizard
  before_action :authorize_user

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      user = @wizard.create_user
      User::Invite.call(user:, organisation: @provider)
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success"),
        body: t(".success_body", user_name: user.first_name, provider_name: @provider.name),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::AddUserWizard.new(organisation: @provider, params:, state:, current_step:)
  end

  def authorize_user
    authorize Claims::ProviderUser
  end

  def step_path(step)
    add_user_claims_provider_users_path(@provider, state_key:, step:)
  end

  def index_path
    claims_provider_users_path(@provider)
  end
end
