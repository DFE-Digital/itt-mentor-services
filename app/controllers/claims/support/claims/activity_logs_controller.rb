class Claims::Support::Claims::ActivityLogsController < Claims::Support::ApplicationController
  before_action :set_activity_log, only: %i[show]
  before_action :authorize_activity_log

  def index
    @pagy, @activity_logs = pagy(Claims::ActivityLog.order(created_at: :desc))
  end

  def show; end

  private

  def set_activity_log
    @activity_log = Claims::ActivityLog.find(params.require(:id))
  end

  def authorize_activity_log
    authorize @activity_log || Claims::ActivityLog
  end

  def authorize(record)
    super([:claims, :support, :claims, record])
  end
end
