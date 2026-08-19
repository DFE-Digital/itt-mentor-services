class Claims::Providers::Claims::RejectController < Claims::Providers::ApplicationController
  include WizardController

  before_action :set_provider
  before_action :set_claim
  before_action :authorize_claim
  before_action :set_wizard

  helper_method :index_path, :back_link_path

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.process_submission
      @wizard.reset_state

      redirect_to index_path, flash: {
        heading: t(".success"),
      }
    end
  end

  private

  def set_claim
    @claim = provider_claims.find(params.require(:id))
  end

  def authorize_claim
    authorize @claim, :reject?
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::Providers::ApproveRejectSamplingClaimWizard.new(
      claim: @claim,
      current_user: current_user,
      action: "reject",
      params:,
      state:,
      current_step:,
    )
    @wizard.setup_state if state.empty?
  end

  def step_path(step)
    reject_claims_provider_claim_path(@provider, @claim, state_key:, step:)
  end

  def index_path
    claims_provider_claims_path(@provider)
  end

  def back_link_path
    claims_provider_claim_path(@provider, @claim)
  end

  def provider_claims
    @provider_claims ||= policy_scope(Claims::Claim.where(provider: @provider))
      .includes(:school, :provider, :claim_window, mentor_trainings: :mentor)
      .not_draft_status
      .where(status: Claims::Providers::Claims::StatusesQuery.values)
  end
end
