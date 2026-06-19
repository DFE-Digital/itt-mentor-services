class Claims::Providers::ApplicationPolicy < Claims::ApplicationPolicy
  def read?
    user.support_user? || provider_user?
  end

  def create?
    user.support_user?
  end

  def update?
    user.support_user?
  end

  def destroy?
    user.support_user?
  end

  private

  def provider_user?
    user.is_a?(Claims::ProviderUser)
  end
end
