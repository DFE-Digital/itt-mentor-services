class Claims::Support::ClaimStatusChangePolicy < Claims::ApplicationPolicy
  def download?
    user.support_user?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.support_user? ? scope.all : scope.none
    end
  end
end
