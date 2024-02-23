class Claims::SupportUserPolicy < Claims::ApplicationPolicy
  def destroy?
    user != record
  end

  def remove?
    destroy?
  end
end
