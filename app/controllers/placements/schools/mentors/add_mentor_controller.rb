class Placements::Schools::Mentors::AddMentorController < Placements::ApplicationController
  before_action :set_school
  before_action :set_wizard

  helper_method :step_path, :current_step_path, :back_link_path

  def new
    @wizard.reset_state
    redirect_to step_path(@wizard.first_step)
  end

  def edit; end

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

  def set_school
    @school = current_user.schools.find(params.require(:school_id))
  end

  def set_wizard
    current_step = params[:step]&.to_sym
    @wizard = Placements::AddMentorWizard.new(school: @school, params:, session:, current_step:)
  end

  def step_path(step)
    add_mentor_placements_school_mentors_path(step:)
  end

  def current_step_path
    step_path(@wizard.current_step)
  end

  def index_path
    placements_school_mentors_path(@school)
  end

  def back_link_path
    if @wizard.previous_step.present?
      step_path(@wizard.previous_step)
    else
      index_path
    end
  end
end
