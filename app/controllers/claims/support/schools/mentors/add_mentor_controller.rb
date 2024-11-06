class Claims::Support::Schools::Mentors::AddMentorController < Claims::ApplicationController
  include WizardController
  include Claims::BelongsToSchool

  before_action :has_school_accepted_grant_conditions?
  before_action :set_wizard
  before_action :authorize_mentor
  before_action :authorize_mentor_membership

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      mentor = @wizard.create_mentor
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success_heading"),
        body: t(".success_body", user_name: mentor.full_name),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::AddMentorWizard.new(school: @school, params:, state:, current_step:)
  end

  def step_path(step)
    add_mentor_claims_support_school_mentors_path(state_key:, step:)
  end

  def index_path
    claims_support_school_mentors_path(@school)
  end

  def authorize_mentor
    authorize Claims::Mentor
  end

  def authorize_mentor_membership
    authorize Claims::MentorMembership
  end
end
