class Claims::Support::Claims::Clawbacks::ClawbackSupportApprovalController < Claims::Support::ApplicationController
  include WizardController
  before_action :skip_authorization
  before_action :set_claim
  before_action :set_wizard
  helper_method :index_path

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.approve_clawback
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".heading"),
        body: t(".body"),
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
    @wizard = Claims::ClawbackSupportApprovalWizard.new(claim: @claim, params:, current_user:, state:, current_step:)
  end

  def step_path(step)
    clawback_support_approval_claims_support_claims_clawback_path(state_key:, step:)
  end

  def index_path
    claims_support_claims_clawbacks_path
  end
end
