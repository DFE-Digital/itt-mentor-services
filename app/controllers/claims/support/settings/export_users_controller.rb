class Claims::Support::Settings::ExportUsersController < Claims::Support::ApplicationController
  include WizardController

  before_action :set_wizard
  before_action :authorize_user

  helper_method :index_path

  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    end
  end

  def download
    claim_window_id = params[:claim_window]
    activity_level = params[:activity_level]
    csv = Claims::ExportUsers.call(
      claim_window_id:,
      activity_level:,
    )

    send_data csv,
              filename: "exported_users_#{Time.zone.today}.csv",
              type: "text/csv"
  end

  private

  def authorize_user
    authorize Claims::User
  end

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::ExportUsersWizard.new(params:, state:, current_step:)
  end

  def step_path(step)
    claims_support_claims_export_users_path(state_key:, step:)
  end

  def index_path
    claims_support_settings_path
  end
end
