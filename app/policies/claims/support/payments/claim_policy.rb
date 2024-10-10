class Claims::Support::Payments::ClaimPolicy < Claims::ApplicationPolicy
  def information_sent?
    user.support_user? && record.payment_information_requested?
  end
  alias_method :check_information_sent?, :information_sent?

  def reject?
    user.support_user? && record.payment_information_requested?
  end
  alias_method :check_reject?, :reject?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(status: %i[payment_information_requested payment_information_sent])
    end
  end
end
