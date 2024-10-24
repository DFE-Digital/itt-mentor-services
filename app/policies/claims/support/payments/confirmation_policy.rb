class Claims::Support::Payments::ConfirmationPolicy < Claims::ApplicationPolicy
  def new?
    true
  end

  def create?
    Claims::Claim.where(status: %i[payment_information_sent payment_information_requested]).any?
  end
end
