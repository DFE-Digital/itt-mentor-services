class Claims::Support::Claims::PaymentResponsePolicy < Claims::ApplicationPolicy
  def new?
    true
  end

  def update?
    Claims::Claim.payment_in_progress.any?
  end
end
