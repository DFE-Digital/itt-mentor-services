class Placements::Schools::SchoolContacts::EditSchoolContactController < Placements::ApplicationController
  before_action :set_school
  before_action :set_school_contact
  before_action :set_wizard

  helper_method :step_path, :current_step_path, :back_link_path, :add_mentor_path

  def new
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
      redirect_to placements_school_path(@school), flash: {
        heading: t(".success_heading"),
      }
    end
  end

  private

  def set_school_contact
    school_contact_id = params.require(:id)
    @school_contact = Placements::SchoolContact.find_by!(id: school_contact_id, school: @school)
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::EditSchoolContactWizard.new(school: @school, school_contact: @school_contact, params:, state:, current_step:)
  end

  def step_path(step)
    edit_school_contact_placements_school_school_contact_path(state_key:, step:)
  end

  def state_key
    @state_key ||= params.fetch(:state_key, BaseWizard.generate_state_key)
  end

  def current_step_path
    step_path(@wizard.current_step)
  end

  def back_link_path
    placements_school_path(@school)
  end
end
