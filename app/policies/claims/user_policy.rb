class Claims::UserPolicy < Claims::ApplicationPolicy
  def destroy?
    user != record
  end
end
