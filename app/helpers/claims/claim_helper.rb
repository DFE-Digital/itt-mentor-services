module Claims::ClaimHelper
  def claim_statuses_for_selection
    Claims::Claim.statuses.values.reject { |status|
      Claims::Claim::DRAFT_STATUSES.map(&:to_s).include?(status)
    }.sort
  end
end
