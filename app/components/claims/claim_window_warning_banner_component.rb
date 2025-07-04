class Claims::ClaimWindowWarningBannerComponent < ApplicationComponent
  private

  def render?
    hours_until_claim_window_closes >= 0 && days_until_claim_window_closes <= 30
  end

  def days_until_claim_window_closes
    (Claims::ClaimWindow.current.ends_on - Date.current).to_i
  end

  def hours_until_claim_window_closes
    (Time.current.seconds_until_end_of_day / 1.hour).to_i
  end

  def minutes_until_claim_window_closes
    ((Time.current.seconds_until_end_of_day % 1.hour) / 1.minute).to_i
  end

  def claim_window_today?
    Claims::ClaimWindow.current.ends_on == Date.current
  end
end
