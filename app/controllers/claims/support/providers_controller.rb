class Claims::Support::ProvidersController < Claims::Support::ApplicationController
  before_action :authorize_provider
  def search
    limit = params[:limit].to_i.clamp(25, 100)
    providers = default_claims.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].presence
    providers ||= default_claims

    render json: providers.limit(limit).as_json(only: %i[id name])
  end

  private

  def authorize_provider
    authorize Claims::Provider
  end

  def default_claims
    @default_claims ||= Claims::Provider.accredited.excluding_niot_providers
  end
end
