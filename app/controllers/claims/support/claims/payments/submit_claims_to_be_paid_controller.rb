class Claims::Support::Claims::Payments::SubmitClaimsToBePaidController < Claims::Support::ApplicationController
  include WizardController
  before_action :skip_authorization

  before_action :set_wizard
  helper_method :index_path

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.pay_claims
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".heading"),
        body: t(".body_html"),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::SubmitClaimsToBePaidWizard.new(params:, state:, current_step:, current_user:)
  end

  def step_path(step)
    submit_claims_to_be_paid_claims_support_claims_payments_path(state_key:, step:)
  end

  def index_path
    claims_support_claims_payments_path
  end
end
