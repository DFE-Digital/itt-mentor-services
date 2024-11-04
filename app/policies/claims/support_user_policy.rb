class Claims::SupportUserPolicy < Claims::ApplicationPolicy
  def update?
    true
  end

  def destroy?
    user != record
  end

  def remove?
    destroy?
  end
end
