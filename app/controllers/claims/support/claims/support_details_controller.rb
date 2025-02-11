class Claims::Support::Claims::SupportDetailsController < Claims::Support::ApplicationController
  include WizardController
  before_action :skip_authorization

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
      @wizard.update_support_details
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: @wizard.success_message,
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params.fetch(:step).to_sym
    @wizard = Claims::SupportDetailsWizard.new(params:, claim:, state:, current_step:)
  end

  def step_path(step)
    support_details_claims_support_claim_path(state_key:, step:)
  end

  def claim
    @claim ||= Claims::Claim.find(params.require(:id))
  end

  def index_path
    claims_support_claim_path(claim)
  end
end
