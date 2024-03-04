class ClaimPolicy < Claims::ApplicationPolicy
  def update?
    true
  end

  def submit?
    true
  end

  def confirm?
    true
  end
end
