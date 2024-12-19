class Claims::Support::Claims::Payments::ClaimPolicy < Claims::ApplicationPolicy
  def update?
    false
  end
end
