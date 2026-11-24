class Claims::Support::ForecastsController < Claims::Support::ApplicationController
  before_action :skip_authorization

  def show
    @claim_windows = Claims::ClaimWindow.order(starts_on: :desc).decorate
    @claim_window = Claims::ClaimWindow.find_by(id: params[:claim_window_id])
    return unless @claim_window

    @forecast = Claims::Claim::Forecast.call(claim_window: @claim_window, status: :submitted)
    @total_claims = Claims::Claim::Forecast.call(claim_window: @claim_window)
    clawbacks = Claims::Claim::Forecast.clawbacks(claim_window: @claim_window)
    @pending_clawbacks = clawbacks.pending
    @completed_clawbacks = clawbacks.completed
  end
end
