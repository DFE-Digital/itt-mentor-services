class Claims::Support::Claims::RequestClawbackController < Claims::ApplicationController
  include WizardController
  before_action :skip_authorization
  before_action :set_claim
  before_action :set_wizard

  def new
    @wizard.reset_state
    redirect_to step_path(@wizard.first_step)
  end

  def edit; end

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.update_status
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success_heading"),
      }
    end
  end

  private

  def set_claim
    @claim = Claims::Claim.find(params[:claim_id])
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::RequestClawbackWizard.new(claim: @claim, params:, state:, current_step:)
  end

  def step_path(step)
    request_clawback_claims_support_claims_clawbacks_path(state_key:, step:)
  end

  def index_path
    claims_support_claims_clawbacks_path
  end
end
