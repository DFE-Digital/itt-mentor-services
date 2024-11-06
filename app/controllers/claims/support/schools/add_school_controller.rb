class Claims::Support::Schools::AddSchoolController < Claims::Support::ApplicationController
  include WizardController

  before_action :authorize_school
  before_action :set_wizard

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.onboard_school
      @wizard.reset_state
      redirect_to claims_support_schools_path, flash: {
        heading: t(".success"),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::AddSchoolWizard.new(params:, state:, current_step:)
  end

  def authorize_school
    authorize Claims::School, policy_class: Claims::SchoolPolicy
  end

  def step_path(step)
    add_school_claims_support_schools_path(state_key:, step:)
  end

  def index_path
    claims_support_schools_path
  end
end
