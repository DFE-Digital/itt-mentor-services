class Claims::Support::Claims::ChangeProviderController < Claims::Support::ApplicationController
  include WizardController

  before_action :set_claim
  before_action :authorize_claim
  before_action :set_wizard

  helper_method :index_path

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.change_provider
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success_heading"),
        body: @wizard.success_message,
      }.compact
    end
  end

  private

  def set_claim
    @claim = Claims::Claim.find(params.require(:id))
  end

  def authorize_claim
    authorize @claim, :change_provider?
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::ChangeProviderWizard.new(claim: @claim, params:, state:, current_step:)
  end

  def step_path(step)
    change_provider_claims_support_claim_path(@claim, state_key:, step:)
  end

  def index_path
    claims_support_claim_path(@claim)
  end
end
