class Placements::Schools::SchoolContacts::EditSchoolContactController < Placements::ApplicationController
  before_action :set_school
  before_action :set_school_contact
  before_action :set_wizard

  helper_method :step_path, :current_step_path, :back_link_path, :add_mentor_path

  def new
    @wizard.reset_state
    @wizard.setup_state
    redirect_to step_path(@wizard.first_step)
  end

  def edit; end

  def update
    if !@wizard.save_step
      render "edit"
    else
      @wizard.update_school_contact
      Placements::SchoolSlackNotifier.school_onboarded_notification(@school).deliver_later
      @wizard.reset_state
      redirect_to placements_school_path(@school), flash: { success: t(".success") }
    end
  end

  private

  def set_school
    school_id = params.require(:school_id)
    @school = current_user.schools.find(school_id)
  end

  def set_school_contact
    @school_contact = @school.school_contact
  end

  def set_wizard
    current_step = params[:step]&.to_sym
    @wizard = Placements::EditSchoolContactWizard.new(school: @school, school_contact: @school_contact, params:, session:, current_step:)
  end

  def step_path(step)
    edit_school_contact_placements_school_school_contact_path(step:)
  end

  def current_step_path
    step_path(@wizard.current_step)
  end

  def back_link_path
    placements_school_path(@school)
  end
end
