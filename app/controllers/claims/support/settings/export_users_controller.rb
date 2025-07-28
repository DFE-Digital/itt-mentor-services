class Claims::Support::Settings::ExportUsersController < Claims::Support::ApplicationController
  include WizardController

  before_action :set_wizard
  before_action :authorize_user

  helper_method :index_path

  def update
    if !@wizard.save_step
      render "edit"
    else
      redirect_to step_path(@wizard.next_step)
    end
  end

  def download
    send_data @wizard.generate_csv,
              filename: "exported_users_#{Time.zone.today.strftime("%Y%m%d")}.csv",
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
