class Claims::UserResearch::SamplingClaims::RejectController < Claims::ApplicationController
  include WizardController
  skip_before_action :authenticate_user!
  before_action :skip_authorization
  before_action :redirect_unless_logged_in
  before_action :set_claim
  before_action :set_wizard

  helper_method :index_path, :back_link_path

  def new
    redirect_to step_path(@wizard.first_step)
  end

  def edit
    render "edit"
  end

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

  def redirect_unless_logged_in
    return if current_provider.present?

    redirect_to claims_root_path
  end

  def set_claim
    @claim = claims_scope.find(params.require(:id))
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::UserResearch::ApproveRejectSamplingClaimWizard.new(
      claim: @claim,
      current_user: current_provider,
      action: "reject",
      params:,
      state:,
      current_step:,
    )
    @wizard.setup_state if state.empty?
  end

  def step_path(step)
    reject_claim_claims_user_research_provider_claim_path(
      provider_claim: @claim,
      state_key:,
      step:,
    )
  end

  def index_path
    claims_user_research_provider_claims_path
  end

  def back_link_path
    claims_user_research_provider_claim_path(@claim)
  end

  def claims_scope
    Claims::Claim.not_draft_status.includes(
      :claim_window,
      :provider,
      :academic_year,
      :mentor_trainings,
      :support_user,
      school: :region,
    ).where(provider_id: prototype_provider_ids)
  end

  def prototype_provider_ids
    @prototype_provider_ids ||= Claims::Provider.where(name: current_provider.name).select(:id)
  end

  def current_provider
    @current_provider ||= prototype.provider_for(code: session[:provider_research_code])
  end

  def prototype
    @prototype ||= Claims::UserResearch::ProviderClaimsPrototype.new
  end
end
