class Claims::Support::Claims::Samplings::UploadDataController < Claims::Support::ApplicationController
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
      @wizard.upload_data
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".heading"),
        body: t(".body"),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::UploadSamplingDataWizard.new(params:, state:, current_step:, current_user:)
  end

  def step_path(step)
    upload_data_claims_support_claims_samplings_path(state_key:, step:)
  end

  def index_path
    claims_support_claims_samplings_path
  end
end
