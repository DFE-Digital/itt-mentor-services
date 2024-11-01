class Claims::UserPolicy < Claims::ApplicationPolicy
  def update?
    true
  end

  def destroy?
    user != record
  end
end
