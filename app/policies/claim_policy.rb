class ClaimPolicy < Claims::ApplicationPolicy
  def update?
    true
  end
end
