class Claims::Support::Claims::Clawbacks::ClawbackSupportApprovalController < Claims::Support::ApplicationController
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
      @wizard.approve_clawback
      @wizard.reset_state
      @claim.reload
      if @claim.clawback_requested?
        redirect_to index_path, flash: {
          heading: t(".approved.heading"),
          body: t(".approved.body"),
        }
      else
        redirect_to index_path, flash: {
          heading: t(".rejected.heading"),
          body: t(".rejected.body", support_user_name: @claim.clawback_requested_by.full_name),
        }
      end
    end
  end

  private

  def set_claim
    @claim = Claims::Claim.find(params[:id])
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
    claims_support_claims_clawback_path(@claim)
  end

  def authorize_claim
    authorize @claim, :approve_clawback?
  end
end
