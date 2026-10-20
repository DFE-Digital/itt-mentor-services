class Claims::Support::Claims::Samplings::OverrideController < Claims::Support::ApplicationController
  include WizardController

  before_action :skip_authorization
  before_action :set_claim
  before_action :require_provider_rejected
  before_action :set_wizard
  helper_method :index_path

  def new
    @wizard.reset_state
    @wizard.setup_state
    redirect_to step_path(@wizard.first_step)
  end

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.process_submission
      @wizard.reset_state

      if @wizard.clawback_requested?
        redirect_to claims_support_claims_clawback_path(@claim), flash: { heading: t(".clawback_requested") }
      else
        redirect_to claims_support_claims_path, flash: { heading: t(".no_clawback_required") }
      end
    end
  end

  private

  def set_claim
    @claim = Claims::Claim.find(params.require(:id))
  end

  def require_provider_rejected
    redirect_to index_path unless @claim.sampling_provider_not_approved?
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::Providers::ApproveRejectSamplingClaimWizard.new(
      claim: @claim,
      current_user:,
      action: "override",
      params:,
      state:,
      current_step:,
    )
  end

  def step_path(step)
    override_claims_support_claims_sampling_path(@claim, state_key:, step:)
  end

  def index_path
    claims_support_claims_sampling_path(@claim)
  end
end
