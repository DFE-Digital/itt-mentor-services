class Placements::SupportUserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.support_user?
        scope
      else
        scope.none
      end
    end
  end

  def destroy?
    user != record
  end

  def remove?
    destroy?
  end
end
