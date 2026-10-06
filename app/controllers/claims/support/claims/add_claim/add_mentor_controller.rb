class Claims::Support::Claims::AddClaim::AddMentorController < Claims::Support::ApplicationController
  include WizardController

  before_action :set_school
  before_action :set_wizard
  before_action :require_mentor_details
  before_action :authorize_mentor
  before_action :authorize_mentor_membership

  helper_method :index_path

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.create_mentor
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success_heading"),
        body: t(".success_body", mentor_name: @wizard.steps[:mentor].mentor.first_name),
      }
    end
  end

  private

  def claim_state_key
    params.require(:claim_state_key)
  end

  def claim_wizard
    ::Claims::AddExceptionalClaimWizard.new(
      created_by: current_user,
      params: ActionController::Parameters.new,
      state: session[claim_state_key] || {},
      current_step: :school,
    )
  end

  def set_school
    @school = claim_wizard.school
    redirect_to new_add_claim_claims_support_claims_path if @school.blank?
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = ::Claims::AddMentorWizard.new(school: @school, params:, state:, current_step:)
  rescue BaseWizard::StepNotFoundError
    redirect_to new_add_claim_add_mentor_claims_support_claims_path(claim_state_key:)
  end

  def require_mentor_details
    return unless @wizard.current_step == :check_your_answers && @wizard.steps[:mentor].invalid?

    redirect_to step_path(:mentor)
  end

  def authorize_mentor
    authorize ::Claims::Mentor, :create?
  end

  def authorize_mentor_membership
    authorize ::Claims::MentorMembership, :create?
  end

  def step_path(step)
    add_claim_add_mentor_claims_support_claims_path(claim_state_key:, state_key:, step:)
  end

  def index_path
    add_claim_claims_support_claims_path(
      state_key: claim_state_key,
      step: claim_wizard.steps.key?(:mentor) ? :mentor : :no_mentors,
    )
  end
end
