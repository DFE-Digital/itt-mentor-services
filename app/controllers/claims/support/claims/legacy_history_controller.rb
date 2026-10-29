class Claims::Support::Claims::LegacyHistoryController < Claims::Support::ApplicationController
  def show
    @claim = policy_scope(Claims::Claim).find(params.require(:claim_id))
    authorize @claim, :legacy_history?

    @audits_pagy, @audits = pagy(Claims::ClaimLegacyAuditsQuery.call(claim: @claim), page_param: :audit_page)
    @activities_pagy, @activities = pagy(Claims::ClaimLegacyActivitiesQuery.call(claim: @claim), page_param: :activity_page)
    @activities = @activities.decorate
  end
end
