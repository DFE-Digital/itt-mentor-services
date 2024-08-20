class Claims::Support::Claims::Payments::ConfirmationPolicy < Claims::ApplicationPolicy
  def new?
    true
  end

  def create?
    Claims::Claim.where(status: %i[payment_in_progress payment_information_sent payment_information_requested]).any?
  end
end
