class Claims::Support::Schools::Claims::EditClaimController < Claims::Support::ApplicationController
  include WizardController
  include Claims::BelongsToSchool

  before_action :has_school_accepted_grant_conditions?
  before_action :set_wizard
  before_action :authorize_claim

  helper_method :index_path

  def new
    @wizard.setup_state
    redirect_to step_path(params.require(:step).to_sym)
  end

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    elsif @wizard.valid?
      @wizard.update_claim
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success"),
      }
    else
      redirect_to rejected_claims_school_claims_path(@school)
    end
  end

  private

  def claim
    @claim = @school.claims.find(params.require(:id))
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params.require(:step).to_sym
    @wizard = Claims::EditClaimWizard.new(
      school: @school, claim:, created_by: current_user, params:, state:, current_step:,
    )
  end

  def authorize_claim
    authorize claim, :update?
  end

  def step_path(step)
    edit_claim_claims_support_school_claim_path(@school, claim, state_key:, step:)
  end

  def index_path
    claims_support_school_claim_path(@school, claim)
  end
end
