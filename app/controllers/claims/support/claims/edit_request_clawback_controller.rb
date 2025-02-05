class Claims::Support::Claims::EditRequestClawbackController < Claims::ApplicationController
  include WizardController
  before_action :skip_authorization
  before_action :set_claim
  before_action :set_wizard
  helper_method :index_path

  def new
    @wizard.setup_state
    redirect_to step_path(@wizard.first_step)
  end

  def update
    if !@wizard.save_step
      render "edit"
    else
      @wizard.update_clawback
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
    @wizard = Claims::EditRequestClawbackWizard.new(claim: @claim, current_user:, params:, state:, mentor_training_id:, current_step:)
  end

  def step_path(step)
    edit_request_clawback_claims_support_claims_clawback_path(claim: @claim, mentor_training_id:, state_key:, step:)
  end

  def mentor_training_id
    params.fetch(:mentor_training_id)
  end

  def index_path
    claims_support_claims_clawback_path(@claim)
  end
end
