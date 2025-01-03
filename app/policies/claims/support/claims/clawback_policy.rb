class Claims::Support::Claims::ClawbackPolicy < Claims::ApplicationPolicy
  def new?
    true
  end

  def create?
    Claims::Claim.clawback_requested.any?
  end
end
