class Claims::Schools::Claims::InvalidProviderController < Claims::ApplicationController
  include WizardController
  include Claims::BelongsToSchool

  before_action :set_wizard
  before_action :authorize_claim

  helper_method :index_path

  def update
    if @wizard.valid?
      @wizard.update_claim
      @wizard.reset_state
      redirect_to confirmation_claims_school_claim_path(@school, @wizard.claim)
    else
      render "edit"
    end
  end

  private

  def claim
    @claim = @school.claims.find(params.require(:id))
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params.require(:step).to_sym
    @wizard = Claims::InvalidProviderWizard.new(
      school: @school, claim:, created_by: current_user, params:, state:, current_step:,
    )
  end

  def authorize_claim
    authorize claim, :invalid_provider?
  end

  def step_path(step)
    invalid_provider_claims_school_claim_path(@school, claim, state_key:, step:)
  end

  def index_path
    claims_school_claim_path(@school, claim)
  end
end
