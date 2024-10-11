class Placements::Schools::Mentors::AddMentorController < Placements::ApplicationController
  before_action :set_school
  before_action :set_wizard

  helper_method :step_path, :current_step_path, :back_link_path

  def new
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

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::AddMentorWizard.new(school: @school, params:, state:, current_step:)
  end

  def step_path(step)
    add_mentor_placements_school_mentors_path(state_key:, step:)
  end

  def state_key
    @state_key ||= params.fetch(:state_key, Placements::BaseWizard.generate_state_key)
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
