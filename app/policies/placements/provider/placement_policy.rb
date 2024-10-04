class Placements::Provider::PlacementPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope
    end
  end
end
