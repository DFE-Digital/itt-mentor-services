class Placements::SupportUserPolicy < ApplicationPolicy
  def destroy?
    user != record
  end
end
