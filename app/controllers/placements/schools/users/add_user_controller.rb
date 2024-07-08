class Placements::Schools::Users::AddUserController < Placements::ApplicationController
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
      user = @wizard.create_user
      User::Invite.call(user: user, organisation: @organisation)
      redirect_to placements_school_users_path(@school), flash: { success: t(".success") }
    end
  end

  private

  def set_school
    school_id = params.require(:school_id)
    @school = current_user.schools.find(school_id)
  end

  def set_wizard
    current_step = params[:step]&.to_sym
    @wizard = Placements::AddUserWizard.new(organisation: @school, params:, session:, current_step:)
  end

  def step_path(step)
    add_user_placements_school_users_path(step:)
  end

  def current_step_path
    step_path(@wizard.current_step)
  end

  def back_link_path
    if @wizard.previous_step.present?
      step_path(@wizard.previous_step)
    else
      placements_school_users_path(@school)
    end
  end
end
