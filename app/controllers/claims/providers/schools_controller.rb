class Claims::Providers::SchoolsController < Claims::Providers::ApplicationController
  before_action :set_provider

  def search
    authorize Claims::Claim

    limit = params[:limit].to_i.clamp(25, 100)
    schools = Claims::School.where(id: provider_claims.select(:school_id)).distinct
    schools = schools.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?

    render json: schools.order(:name).limit(limit).as_json(only: %i[id name])
  end

  private

  def provider_claims
    @provider_claims ||= policy_scope(Claims::Claim.where(provider: @provider)).not_draft_status
  end
end
