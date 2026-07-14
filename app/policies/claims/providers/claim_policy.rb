class Claims::Providers::ClaimPolicy < Claims::Providers::ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?
      return scope.none unless provider_user?

      scope.where(provider_id: user.providers.select(:id))
    end

    private

    def provider_user?
      user.is_a?(Claims::ProviderUser)
    end
  end

  def read?
    return true if user.support_user?
    return false unless provider_user?

    user.providers.exists?(id: record.provider_id)
  end
end
