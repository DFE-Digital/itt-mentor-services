class Placements::Schools::SchoolContacts::AddSchoolContactController < Placements::ApplicationController
  before_action :set_school
  before_action :set_wizard
  before_action :authorize_school_contact

  helper_method :step_path, :current_step_path, :back_link_path, :add_mentor_path

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
      @wizard.create_school_contact
      Placements::SchoolSlackNotifier.school_onboarded_notification(@school).deliver_later
      @wizard.reset_state
      redirect_to placements_school_path(@school), flash: {
        heading: t(".success_heading"),
      }
    end
  end

  private

  def set_school
    school_id = params.require(:school_id)
    @school = current_user.schools.find(school_id)
  end

  def set_wizard
    current_step = params[:step]&.to_sym
    @wizard = Placements::AddSchoolContactWizard.new(school: @school, params:, session:, current_step:)
  end

  def step_path(step)
    add_school_contact_placements_school_school_contacts_path(step:)
  end

  def current_step_path
    step_path(@wizard.current_step)
  end

  def back_link_path
    if @wizard.previous_step.present?
      step_path(@wizard.previous_step)
    else
      placements_school_path(@school)
    end
  end

  def authorize_school_contact
    authorize @school.build_school_contact, :add_school_contact_journey?
  end
end
