class Claims::Support::Schools::Claims::AddClaimController < Claims::Support::ApplicationController
  include WizardController
  include Claims::BelongsToSchool

  before_action :has_school_accepted_grant_conditions?
  before_action :set_wizard
  before_action :authorize_claim

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    elsif @wizard.valid?
      @wizard.create_claim
      @wizard.reset_state
      redirect_to claims_support_school_claims_path(@school), flash: {
        heading: t(".success"),
      }
    else
      redirect_to rejected_claims_support_school_claim_path(@school)
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::AddClaimWizard.new(
      school: @school, created_by: current_user, params:, state:, current_step:,
    )
  end

  def authorize_claim
    authorize Claims::Claim, :create?
  end

  def step_path(step)
    add_claim_claims_support_school_claims_path(state_key:, step:)
  end

  def index_path
    claims_support_school_claims_path(@school)
  end
end
