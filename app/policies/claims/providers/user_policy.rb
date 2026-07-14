class Claims::Providers::UserPolicy < Claims::Providers::ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?
      return scope.none unless provider_user?

      scope.joins(:user_memberships).where(user_memberships: { organisation: user.providers }).distinct
    end

    private

    def provider_user?
      user.is_a?(Claims::ProviderUser)
    end
  end

  def read?
    return true if user.support_user?
    return false unless provider_user?

    record.user_memberships.where(organisation: user.providers).exists?
  end
end
