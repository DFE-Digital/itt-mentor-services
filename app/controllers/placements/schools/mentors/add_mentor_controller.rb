class Placements::Schools::Mentors::AddMentorController < Placements::ApplicationController
  include WizardController

  before_action :set_school
  before_action :set_wizard

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
    @wizard = Placements::AddMentorWizard.new(school: @school, params:, state:, current_step:)
  end

  def step_path(step)
    add_mentor_placements_school_mentors_path(state_key:, step:)
  end

  def index_path
    placements_school_mentors_path(@school)
  end
end
