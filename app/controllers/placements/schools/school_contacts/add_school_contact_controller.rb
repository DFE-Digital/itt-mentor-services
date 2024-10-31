class Placements::Schools::SchoolContacts::AddSchoolContactController < Placements::ApplicationController
  include WizardController

  before_action :set_school
  before_action :set_wizard
  before_action :authorize_school_contact

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

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::AddSchoolContactWizard.new(school: @school, params:, state:, current_step:)
  end

  def step_path(step)
    add_school_contact_placements_school_school_contacts_path(state_key:, step:)
  end

  def index_path
    placements_school_path(@school)
  end

  def authorize_school_contact
    authorize @school.build_school_contact, :add_school_contact_journey?
  end
end
