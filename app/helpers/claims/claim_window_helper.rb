module Claims::ClaimWindowHelper
  def claim_window_status_tag(claim_window)
    if claim_window.current?
      govuk_tag text: t(".current"), colour: "green"
    elsif claim_window.future?
      govuk_tag text: t(".upcoming"), colour: "light-blue"
    else
      govuk_tag text: t(".past"), colour: "grey"
    end
  end
end
