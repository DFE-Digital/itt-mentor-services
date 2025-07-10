class Claims::ClaimsQuery < ApplicationQuery
  def call
    scope = Claims::Claim.not_draft_status.includes(:claim_window, :provider, :academic_year, :mentor_trainings, school: :region)
    scope = search_condition(scope)
    scope = school_condition(scope)
    scope = provider_condition(scope)
    scope = submitted_after(scope)
    scope = submitted_before(scope)
    scope = status_condition(scope)
    scope = academic_year_condition(scope)
    scope = mentor_condition(scope)

    scope.order_created_at_desc
  end

  private

  def search_condition(scope)
    return scope if params[:search].blank?

    scope.where(Claims::Claim.arel_table[:reference].matches("%#{params[:search]}%"))
  end

  def school_condition(scope)
    return scope if params[:school_ids].blank?

    scope.where(school_id: params[:school_ids])
  end

  def provider_condition(scope)
    return scope if params[:provider_ids].blank?

    scope.where(provider_id: params[:provider_ids])
  end

  def submitted_after(scope)
    return scope if params[:submitted_after].nil?

    scope.where(submitted_at: params[:submitted_after]..)
  end

  def submitted_before(scope)
    return scope if params[:submitted_before].nil?

    scope.where(submitted_at: ..params[:submitted_before])
  end

  def status_condition(scope)
    return scope if params[:statuses].blank?

    scope.where(status: params[:statuses].reject(&:blank?))
  end

  def academic_year_condition(scope)
    return scope if params[:academic_year_id].blank?

    scope.where(claim_window_id: Claims::ClaimWindow.select(:id).where(academic_year_id: params[:academic_year_id]))
  end

  def mentor_condition(scope)
    return scope if params[:mentor_ids].blank?

    scope.where(mentor_trainings: { mentor_id: params[:mentor_ids] })
  end
end
