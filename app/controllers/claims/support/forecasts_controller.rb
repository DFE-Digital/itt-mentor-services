class Claims::Support::ForecastsController < Claims::Support::ApplicationController
  before_action :skip_authorization

  def show
    @claim_windows = Claims::ClaimWindow.order(starts_on: :desc).decorate
    @claim_window = Claims::ClaimWindow.find_by(id: params[:claim_window_id])
    @forecast = Claims::Claim::Forecast.call(claim_window: @claim_window) if @claim_window
  end
end
