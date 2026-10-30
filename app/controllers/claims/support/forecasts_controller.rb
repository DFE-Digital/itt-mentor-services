class Claims::Support::ForecastsController < Claims::Support::ApplicationController
  before_action :skip_authorization

  def show
    @claim_windows = Claims::ClaimWindow.order(starts_on: :desc).decorate
    @claim_window = Claims::ClaimWindow.find_by(id: params[:claim_window_id])
    return unless @claim_window

    @forecast = Claims::Claim::Forecast.call(claim_window: @claim_window, status: :submitted)
    @total_claims = Claims::Claim::Forecast.call(claim_window: @claim_window)
    @pending_clawbacks = Claims::Claim::Forecast.call(
      claim_window: @claim_window,
      status: %i[clawback_requires_approval clawback_requested clawback_in_progress],
      clawback: true,
    )
    @completed_clawbacks = Claims::Claim::Forecast.call(claim_window: @claim_window, status: :clawback_complete, clawback: true)
  end
end
