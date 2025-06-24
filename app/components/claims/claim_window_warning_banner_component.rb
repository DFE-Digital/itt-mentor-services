class Claims::ClaimWindowWarningBannerComponent < ApplicationComponent
  private

  def render?
    days_until_claim_window_closes <= 30 && days_until_claim_window_closes >= 0
  end

  def days_until_claim_window_closes
    (Claims::ClaimWindow.current.ends_on - Date.current).to_i
  end
end
