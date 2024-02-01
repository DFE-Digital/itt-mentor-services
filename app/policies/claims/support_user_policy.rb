class Claims::SupportUserPolicy < ApplicationPolicy
  def destroy?
    user != record
  end
end
