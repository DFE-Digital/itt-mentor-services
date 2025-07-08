class Claims::Support::ProvidersController < Claims::Support::ApplicationController
  before_action :authorize_provider
  def search
    limit = params[:limit].to_i.clamp(25, 100)
    providers = Claims::Provider.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].presence
    providers ||= Claims::Provider

    render json: providers.limit(limit).as_json(only: %i[id name])
  end

  private

  def authorize_provider
    authorize Claims::Provider
  end
end
