class Placements::Support::SupportUsers::AddSupportUserController < Placements::ApplicationController
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
      support_user = @wizard.create_support_user
      SupportUser::Invite.call(support_user:)
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success_heading"),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Placements::AddSupportUserWizard.new(params:, state:, current_step:)
  end

  def current_step_path
    step_path(@wizard.current_step)
  end

  def step_path(step)
    add_support_user_placements_support_support_users_path(state_key:, step:)
  end

  def state_key
    @state_key ||= params.fetch(:state_key, SecureRandom.uuid)
  end

  def back_link_path
    if @wizard.previous_step.present?
      step_path(@wizard.previous_step)
    else
      index_path
    end
  end

  def index_path
    placements_support_support_users_path
  end
end
