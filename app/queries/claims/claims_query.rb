class Claims::ClaimsQuery < ApplicationQuery
  def call
    scope = Claims::Claim.submitted
    scope = school_condition(scope)
    scope = provider_condition(scope)
    scope.order_created_at_desc
  end

  private

  def school_condition(scope)
    return scope if params[:school_ids].blank?

    scope.where(school_id: params[:school_ids])
  end

  def provider_condition(scope)
    return scope if params[:provider_ids].blank?

    scope.where(provider_id: params[:provider_ids])
  end
end
