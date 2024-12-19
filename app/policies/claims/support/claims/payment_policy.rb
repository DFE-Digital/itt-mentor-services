class Claims::Support::Claims::PaymentPolicy < Claims::ApplicationPolicy
  def new?
    true
  end

  def create?
    Claims::Claim.submitted.any?
  end
end
