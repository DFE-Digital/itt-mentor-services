class Claims::Support::ProviderUserPolicy < Claims::ApplicationPolicy
  def update?
    true
  end

  def download?
    true
  end

  def destroy?
    user != record
  end
end
