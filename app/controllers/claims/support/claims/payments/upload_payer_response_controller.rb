class Claims::Support::Claims::Payments::UploadPayerResponseController < Claims::Support::ApplicationController
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
      # @wizard.upload_provider_responses
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success"),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::UploadPayerPaymentResponseWizard.new(params:, state:, current_step:, current_user:)
  end

  def step_path(step)
    upload_payer_response_claims_support_claims_payments_path(state_key:, step:)
  end

  def index_path
    claims_support_claims_payments_path
  end
end
