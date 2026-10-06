class Claims::Support::Claims::AddClaimController < Claims::Support::ApplicationController
  include WizardController

  before_action :set_wizard
  before_action :authorize_claim

  helper_method :index_path, :add_mentor_path

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    elsif @wizard.valid?
      authorize @wizard.claim, :create_exceptional?
      @wizard.create_claim
      claim = @wizard.claim
      @wizard.reset_state
      redirect_to claims_support_claim_path(claim), flash: {
        heading: t(".success_heading"),
        body: t(".success_body", reference: claim.reference, school_name: claim.school_name),
      }
    else
      redirect_to step_path(first_invalid_step), flash: {
        heading: t(".invalid"),
        success: false,
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = ::Claims::AddExceptionalClaimWizard.new(created_by: current_user, params:, state:, current_step:)
  rescue BaseWizard::StepNotFoundError
    redirect_to new_add_claim_claims_support_claims_path
  end

  def authorize_claim
    authorize ::Claims::Claim, :create_exceptional?
  end

  def first_invalid_step
    @wizard.steps.find { |_name, step| step.invalid? }.first
  end

  def step_path(step)
    add_claim_claims_support_claims_path(state_key:, step:)
  end

  def add_mentor_path
    new_add_claim_add_mentor_claims_support_claims_path(claim_state_key: state_key)
  end

  def index_path
    claims_support_claims_path
  end
end
