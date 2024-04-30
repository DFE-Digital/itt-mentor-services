class HeartbeatController < ApplicationController
  skip_before_action :authenticate_user!

  # disable DfE Analytics request logging for this controller
  skip_after_action :trigger_request_event

  def healthcheck
    checks = { database: database_alive? }
    status = checks.values.all? ? :ok : :service_unavailable

    render(status:, json: { checks: })
  end

  private

  def database_alive?
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      conn.execute("SELECT 1")
    end

    ActiveRecord::Base.connected?
  rescue ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad
    false
  end
end
