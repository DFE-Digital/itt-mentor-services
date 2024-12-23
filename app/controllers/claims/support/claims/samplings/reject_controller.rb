class Claims::Support::Claims::Samplings::RejectController < Claims::Support::ApplicationController
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
      @wizard.reject_claim
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success"),
      }
    end
  end

  private

  def set_claim
    @claim = Claims::Claim.find(params.require(:id))
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::RejectClaimWizard.new(claim: @claim, params:, state:, current_step:)
  end

  def step_path(step)
    reject_claims_support_claims_sampling_path(claim: @claim, state_key:, step:)
  end

  def index_path
    claims_support_claims_sampling_path(@claim)
  end
end
