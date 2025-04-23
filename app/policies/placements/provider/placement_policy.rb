class Placements::Provider::PlacementPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope
    end
  end

  def index?
    Flipper.enabled?(:show_provider_placements)
  end
end
