class Claims::PaymentPolicy < Claims::ApplicationPolicy
  def new?
    true
  end

  def create?
    Claims::Claim.submitted.any?
  end

  def instructions?
    true
  end

  def summary?
    true
  end
end
