class SchoolPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if user.support_user?

      if user.current_organisation.is_a?(Placements::School)
        scope.where(id: user.current_organisation.partner_providers.ids)
      else
        scope.where(id: user.current_organisation.partner_schools.ids)
      end
    end
  end
end
