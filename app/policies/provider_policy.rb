class ProviderPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      scope.where(id: user.current_organisation.partner_providers.select(:id))
    end
  end
end
